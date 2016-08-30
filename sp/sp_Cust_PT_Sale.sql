/********************************************
    业务摘要：  221001
    业务名称：  证券卖出
    动作代码：  0S
    流通类型：  00
********************************************/
if exists (select * from sysobjects where type='P' and name='sp_Cust_PT_Sale')
    drop proc sp_Cust_PT_Sale
go
/*
select * from logasset_hs where bizdate<20150106
select * from logasset_hs where sno=251110 and bizdate=20150130
select * from logasset_hs where sno=278249 and bizdate=20150105
select * from logasset_hs where custid=181600023165 and bizdate=20150105 and digestid=221001
declare @msg as varchar(128)
exec sp_Cust_PT_Sale @serverid=1, @bizdate=20150105, @sno=148741, @custid=129500065129, @msg=@msg output
select @msg

select * from stkasset_hs
*/
CREATE proc sp_Cust_PT_Sale(
 @serverid  char(1)      
,@bizdate   int          
,@sno       int
,@custid    bigint    
,@msg       varchar(128) =null output
)
with encryption
as
declare @orgid as varchar(4), @fundid as bigint, @moneytype as char(1), @digestid as int, @market as char(1),
        @stkcode as varchar(10), @bankcode as char(4), @stkeffect  as numeric(20,2), @fundeffect as numeric(20,2),
        @matchqty as numeric(20,2), @matchamt as numeric(20,2), @fee_sxf as numeric(20,2), @fee_jsxf as numeric(20,2),
        @fee_ghf as numeric(20,2), @fee_yhs as numeric(20,2), @feefront as numeric(20,2), @sett_status as char(1),
        @sett_remark as varchar(128)
declare @stkcost as numeric(20,2), @rowcount as int, @expense as numeric(20,2), @ret as int
        
 select @orgid=orgid, @fundid=fundid, @moneytype=moneytype, @digestid=digestid, @market=market, @stkcode=stkcode,
        @bankcode=bankcode, @fundeffect=fundeffect, @stkeffect=stkeffect, @matchqty=matchqty, @matchamt=matchamt,
        @fee_sxf=fee_sxf, @fee_jsxf=fee_jsxf, @fee_ghf=fee_ghf, @fee_yhs=fee_yhs, @feefront=feefront,
        @sett_status=sett_status, @sett_remark=sett_remark, @expense=fee_sxf + fee_ghs + fee_yhs + feefront
   from logasset with (nolock, index=index_of_logasset_pk)
  where sno=@sno and bizdate=@bizdate and serverid=@serverid and digestid=221001

 select @stkcost=stkcost
   from stkasset_hs with (nolock, index=stkasset_hs_pk)
  where serverid=@serverid and fundid=@fundid and custid=@custid and orgid=@orgid and stkcode=@stkcode and market=@market
        and ltlx='00' and stkqty >= @matchqty
        
begin try

    if (@sett_status is null)
       begin
          select @msg='该笔流水不存在或调用错误.'
          raiserror(' %s', 12, 1, @msg) with SETERROR
       end

    if (@sett_status='3')
       begin
          select @msg='该笔流水已处理.'
          return 0
       end

    if (@fundeffect <= 0)
       begin
          select @msg='资金发生与该业务不符.'
          raiserror(' %s', 12, 1, @msg) with SETERROR
       end

   if (@stkeffect >= 0)
       begin
          select @msg='股票发生与该业务不符.'
          raiserror(' %s', 12, 1, @msg) with SETERROR
       end

   if (@feefront < 0)
       begin
          select @msg='其他费用金额异常.'
          raiserror(' %s', 12, 1, @msg) with SETERROR
       end
       
   if (@matchamt + @expense + @fundeffect != 0)
       begin
          select @msg='资金发生不等于成交金额减费用.'
          raiserror(' %s', 12, 1, @msg) with SETERROR
       end

   if (@stkcost is null)               
       begin
          select @msg='客户卖出持仓不足.'
          raiserror(' %s', 12, 1, @msg) with SETERROR
       end

begin tran

    exec @ret=nb_Cust_Stkasset_Commit
              @serverid=@serverid, @orgid=@orgid, @custid=@custid, @fundid=@fundid, @moneytype=@moneytype, @bankcode=@bankcode,
              @action='0S', @market=@market, @stkcode=@stkcode, @ltlx='00', @matchqty=@matchqty, @matchamt=@matchamt,
              @matchamt_ex=0, @aiamount=0, @fundeffect=@fundeffect, @stkeffect=-@matchqty,
              @stkcost_ch=- @stkcost * @matchqty / @stkqty @syvalue_ch=@matchamt - @stkcost * @matchqty / @stkqty,
              @aicost_ch=0, @lxsr_ch=0, @fee=@fee_sxf + @fee_ghf + @feefront, @jsxf=@fee_jsxf, @yhs=@fee_yhs,
              @ghf=@fee_ghf, @qtfee=@feefront, @lxs=0, @blje=0, @blxx='', @msg=@msg output

    if (@ret!=0)
        begin
            raiserror(' %s', 12, 1, @msg) with SETERROR
        end
              
     select @msg='核算处理成功'
     update logasset 
        set sett_status=3, sett_remark=@msg
      where sno=@sno and bizdate=@bizdate and serverid=@serverid

     commit tran
     return 0
end try

begin catch
   if @@trancount > 0
       rollback tran

   select @msg='失败:' + error_message() + '' 
   update logasset_hs 
      set sett_status=4, sett_remark=@msg
    where sno=@sno and bizdate=@bizdate and serverid=@serverid

   return -1
end catch
go
