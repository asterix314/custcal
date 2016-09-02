/********************************************
    业务摘要：  240509
    业务名称：  基金申购拨出
    动作代码：  0B
    流通类型：  00
********************************************/
if exists (select * from sysobjects where type='P' and name='sp_Cust_JJ_Sgbc')
    drop proc sp_Cust_JJ_Sgbc
go
/*
exec sp_Cust_JJ_Sgbc '1',20150202, 63435, 129500044309, @msg output

*/
CREATE proc sp_Cust_JJ_Sgbc(
 @serverid  int
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
	@sett_remark as varchar(128)
declare @rowcount as int, @expense as numeric(20,2), @ret as int
        
 select @orgid=e.orgid, @fundid=e.fundid, @moneytype=e.moneytype, @digestid=e.digestid, @market=e.market,
        @stkcode=e.stkcode, @bankcode=e.bankcode, @fundeffect=e.fundeffect, @stkeffect=e.stkeffect,
        @matchqty=-fundeffect / p.closeprice, @matchamt=-fundeffect, @sett_status=sett_status,
        @sett_remark=sett_remark
   from logasset_hs e inner join stkprice p
     on e.market = p.market and e.stkcode = p.stkcode and e.bizdate = p.bizdate
  where e.sno=@sno and e.bizdate=@bizdate and e.serverid=@serverid and e.digestid=240509

begin try

    if (@sett_status is null)
       begin
          select @msg='该笔流水不存在或调用错误（没有基金价格？）.'
          raiserror(' %s', 12, 1, @msg) with SETERROR
       end

    if (@sett_status='3')
       begin
          select @msg='该笔流水已处理.'
          return 0
       end

    if (@fundeffect >= 0)
       begin
          select @msg='资金发生与该业务不符.'
          raiserror(' %s', 12, 1, @msg) with SETERROR
       end

begin tran
    exec @ret=nb_Cust_Stkasset_Commit
         @serverid=@serverid, @orgid=@orgid, @custid=@custid, @fundid=@fundid, @moneytype=@moneytype, @bankcode=@bankcode,
	     @action='0B', @market=@market, @stkcode=@stkcode, @ltlx='00', @matchqty=@matchqty, @matchamt=@matchamt,
	     @matchamt_ex=0, @aiamount=0, @fundeffect=@fundeffect, @stkeffect=@stkeffect, @stkcost_ch=@matchamt, @syvalue_ch=0,
	     @aicost_ch=0, @lxsr_ch=0, @fee=0, @jsxf=0, @yhs=0, @ghf=0, @qtfee=0, @lxs=0, @blje=0, @blxx='', @msg=@msg output

    if (@ret!=0)
        begin
            raiserror(' %s', 12, 1, @msg) with SETERROR
        end
              
     select @msg='核算处理成功'
     update logasset_hs
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
