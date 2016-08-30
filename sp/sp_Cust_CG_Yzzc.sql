/********************************************
    业务摘要：  160022
    业务名称：  证券转银行     
    动作代码：  资金操作
    流通类型：  -
********************************************/
if exists (select * from sysobjects where type='P' and name='sp_Cust_CG_Yzzc')
    drop proc sp_Cust_CG_Yzzc
go
/*
select * from logasset where bizdate=20150105 and digestid in (160021,160022)
declare @msg as varchar(128)
exec sp_Cust_CG_Yzzz 20150105, 1, 100, @msg output
select @msg
*/
CREATE proc sp_Cust_CG_Yzzc(
 @serverid  char(1)      
,@bizdate   int          
,@sno       int
,@custid    bigint    
,@msg       varchar(128) =null output
)
with encryption
as
declare @orgid as varchar(4), @fundid as bigint, @moneytype as char(1), @digestid as int, @market as char(1),
        @stkcode as varchar(10), @bankcode as char(4), @fundeffect as numeric(20,2), @stkeffect as numeric(20,2),
        @matchqty as numeric(20,2), @matchamt as numeric(20,2), @fee_sxf as numeric(20,2), @fee_jsxf as numeric(20,2),
        @fee_ghf as numeric(20,2), @fee_yhs as numeric(20,2), @feefront as numeric(20,2), @sett_status as char(1),
        @sett_remark as varchar(128),
declare @rowcount as int, @expense as numeric(20,2), @ret as int
        
 select @orgid=orgid, @fundid=fundid, @moneytype=moneytype, @digestid=digestid, @market=market, @stkcode=stkcode,
        @bankcode=bankcode, @fundeffect=fundeffect, @stkeffect=stkeffect, @matchqty=matchqty, @matchamt=matchamt,
        @fee_sxf=fee_sxf, @fee_jsxf=fee_jsxf, @fee_ghf=fee_ghf, @fee_yhs=fee_yhs, @feefront=feefront,
        @sett_status=sett_status, @sett_remark=sett_remark, @expense=fee_sxf + fee_ghs + fee_yhs + feefront
   from logasset with (nolock, index=index_of_logasset_pk)
  where sno=@sno and bizdate=@bizdate and serverid=@serverid and digestid=160022

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

    if (@fundeffect>=0)
       begin
          select @msg='资金发生与该业务不符.'
          raiserror(' %s', 12, 1, @msg) with SETERROR
       end

begin tran

  update fundasset_hs 
     set fundbal=fundbal+@fundeffect, fundbal_ch=fundbal_ch+@fundeffect
   where moneytype=@moneytype and fundid=@fundid and custid=@custid and orgid=@orgid and serverid=@serverid  
     
  select @rowcount=@@rowcount
      if (@rowcount>1)    
          begin
             select @msg='更新资金行数错误(rowcount='+CONVERT(varchar, @rowcount)+').'       
             raiserror(' %s', 12, 2, @msg) with SETERROR                   
          end
      else if (@rowcount=0)
          begin
             insert fundasset_hs
                   (serverid, orgid, custid, fundid, moneytype, fundlastbal, fundbal, fundbal_ch, 
                   fundsave, fundsave_ch, fundunsave, fundunsave_ch, fundloan, fundloan_ch, funddebt, funddebt_ch, 
                   funduncome, funduncome_ch, fundunpay, fundunpay_ch, fundadjust, fundadjust_ch, fundintr, fundintr_ch, 
                   fundaward, fundaward_ch, bankcode, mktvalue, totalvalue, totalfe, nav, tjdate, remark)
            select @serverid, @orgid, @custid, @fundid, @moneytype, fundlastbal=0, fundbal=@fundeffect, fundbal_ch=@fundeffect, 
                   fundsave=0, fundsave_ch=0, fundunsave=0, fundunsave_ch=0, fundloan=0, fundloan_ch=0, funddebt=0, funddebt_ch=0, 
                   funduncome=0, funduncome_ch=0, fundunpay=0, fundunpay_ch=0, fundadjust=0, fundadjust_ch=0, fundintr=0,
                   fundintr_ch=0,fundaward=0, fundaward_ch=0, @bankcode, mktvalue=0, totalvalue=0, totalfe=0, nav=0, tjdate=0,
                   remark=''     
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

   select @msg='失败:'+error_message()+''
   update logasset_hs 
      set sett_status=4, sett_remark=@msg
    where sno=@sno and bizdate=@bizdate and serverid=@serverid

   return -1
end catch
go
