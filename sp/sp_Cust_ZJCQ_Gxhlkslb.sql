/********************************************
    业务摘要：  140205
    业务名称：  股息红利扣税蓝补
    动作代码：  资金业务
    流通类型：  00
********************************************/
if exists (select * from sysobjects where type='P' and name='sp_Cust_ZJCQ_Gxhlkslb')
    drop proc sp_Cust_ZJCQ_Gxhlkslb
go
/*
declare @msg as varchar(128)
exec sp_Cust_ZJCQ_Gxhlkslb 20150105, 1, 100, @msg output
select @msg
*/
CREATE proc sp_Cust_ZJCQ_Gxhlkslb(
 @serverid  char(1)      
,@bizdate   int          
,@sno       int
,@custid    bigint    
,@msg       varchar(128) =null output
)
with encryption
as
declare @orgid as varchar(4), @fundid as bigint, @moneytype as char(1), @digestid as int, @market as char(1),
        @stkcode as varchar(10), @bankcode as char(4), @fundeffect as numeric(20,2), @stkeffect  as numeric(20,2),
	@matchqty as numeric(20,2), @matchamt as numeric(20,2), @fee_sxf as numeric(20,2), @fee_jsxf as numeric(20,2),
	@fee_ghf as numeric(20,2), @fee_yhs as numeric(20,2), @feefront as numeric(20,2), @sett_status as char(1),
	@sett_remark as varchar(128)
delcare @rowcount as int, @expense as numeric(20,2), @ret as int
        
 select @orgid=orgid, @fundid=fundid, @moneytype=moneytype, @digestid=digestid, @market=market, @stkcode=stkcode,
        @bankcode=bankcode, @fundeffect=fundeffect, @stkeffect=stkeffect, @matchqty=matchqty, @matchamt=matchamt,
	@fee_sxf=fee_sxf, @fee_jsxf=fee_jsxf, @fee_ghf=fee_ghf, @fee_yhs=fee_yhs, @feefront=feefront,
	@sett_status=sett_status, @sett_remark=sett_remark, @expense=fee_sxf + fee_ghs + fee_yhs + feefront
   from logasset with (nolock, index=index_of_logasset_pk)
  where sno=@sno and bizdate=@bizdate and serverid=@serverid and digestid=140205

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

    if (@fundeffect >= 0 or @expense != 0)
       begin
          select @msg='资金发生与该业务不符.'
          raiserror(' %s', 12, 1, @msg) with SETERROR
       end


    if (@stkeffect!=0)
       begin
          select @msg='股票发生与该业务不符.'
          raiserror(' %s', 12, 1, @msg) with SETERROR
       end

begin tran

        -- 更新持仓核算表：利息税
        merge into stkasset_hs as sec
        using (
                select serverid, orgid, custid, fundid, market, stkcode, '00' as ltlx, moneytype, bankcode,
                       fundeffect
                  from logasset_hs
                 where sno=@sno and bizdate=@bizdate and serverid=@serverid and digestid=140205
        ) as ord
        on (
                sec.serverid = ord.serverid and
                sec.orgid = ord.orgid and
                sec.custid = ord.custid and
                sec.fundid = ord.fundid and
                sec.market = ord.market and
                sec.ltlx = ord.ltlx and
                sec.stkcode = ord.stkcode)
        when matched then
                update set lxs = lxs - ord.fundeffect, lxs_ch = lxs_ch - ord.fundeffect
        when not matched then
                insert (serverid, orgid, custid, fundid, market, stkcode, ltlx, lxs, lxs_ch)  
                values (ord.serverid, ord.orgid, ord.custid, ord.fundid, ord.market, ord.stkcode,
                       ord.ltlx, -ord.fundeffect, -ord.fundeffect);

        -- 更新资金核算表：账户资金
        merge into fundasset_hs as fun
        using (
                select serverid, orgid, custid, bankcode, fundid, moneytype, matchamt, fundeffect
                  from logasset_hs
                 where sno=@sno and bizdate=@bizdate and serverid=@serverid and digestid=140205
        ) as ord
        on (
                fun.serverid = ord.serverid and
                fun.orgid = ord.orgid and
                fun.custid = ord.custid and
                fun.bankcode = ord.bankcode and
                fun.fundid = ord.fundid and
                fun.moneytype = ord.moneytype
        )
        when matched then
                update set fundbal = fundbal + ord.fundeffect, fundbal_ch = ord.fundeffect
        when not matched then
                insert (serverid, orgid, custid, bankcode, fundid, moneytype, fundbal, fundbal_ch)  
                values (ord.serverid, ord.orgid, ord.custid, ord.bankcode, ord.fundid, ord.moneytype,
                       ord.fundeffect, ord.fundeffect);




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
