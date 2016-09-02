/********************************************
    ҵ��ժҪ��  220004
    ҵ�����ƣ�  �¹�����
    �������룺  ZR/ZC
    ��ͨ���ͣ�  00
********************************************/
if exists (select * from sysobjects where type='P' and name='sp_Cust_XG_XGRZ')
    drop proc sp_Cust_XG_XGRZ
go
/*
select * from logasset where custid=125500019841 and LEFT(stkcode,6)='002746' order by bizdate,sno
declare @msg as varchar(128)
exec sp_Cust_XG_XGSG 20150209, 124191, 125500019841, @msg output
select @msg
declare @msg as varchar(128)
exec sp_Cust_XG_SGFK 20150211, 128546, 125500019841, @msg output
select @msg
declare @msg as varchar(128)
exec sp_Cust_XG_XGZQ 20150211, 128547, 125500019841, @msg output
select @msg
declare @msg as varchar(128)
exec sp_Cust_XG_XGRZ 20150212, 166617, 125500019841, @msg output
select @msg

select * from stkasset_hs where custid=125500019841 and LEFT(stkcode,6)='002746'
*/
CREATE proc sp_Cust_XG_XGRZ(
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
declare @tx_stkcost as numeric(20,2), @rowcount as int, @expense as numeric(20,2), @ret as int,
        @ref_stkcode as varchar(10), @ref_market as char(1), @stkprice as numeric(12,4)
        
 select @orgid=orgid, @fundid=fundid, @moneytype=moneytype, @digestid=digestid, @market=market, @stkcode=stkcode,
        @bankcode=bankcode, @fundeffect=fundeffect, @stkeffect=stkeffect, @matchqty=matchqty, @matchamt=matchamt,
        @fee_sxf=fee_sxf, @fee_jsxf=fee_jsxf, @fee_ghf=fee_ghf, @fee_yhs=fee_yhs, @feefront=feefront,
        @sett_status=sett_status, @sett_remark=sett_remark, @expense=fee_sxf + fee_ghs + fee_yhs + feefront
   from logasset with (nolock, index=index_of_logasset_pk)
  where sno=@sno and bizdate=@bizdate and serverid=@serverid and digestid=220006


begin try
   if (@sett_status is null)
      begin
          select @msg='�ñ���ˮ�����ڻ���ô���.'
          raiserror(' %s', 12, 1, @msg) with SETERROR
       end

    if (@sett_status='3')
       begin
          select @msg='�ñ���ˮ�Ѵ���.'
          return 0
       end

    if (@fundeffect!=0)
       begin
          select @msg='�ʽ������ҵ�񲻷�.'
          raiserror(' %s', 12, 1, @msg) with SETERROR
       end

    if (@stkeffect<=0)
       begin
          select @msg='��Ʊ�������ҵ�񲻷�.'
          raiserror(' %s', 12, 1, @msg) with SETERROR
       end

   -- �൱���ڲ�ת�йܣ���ͨ����Ϊ01��
  select @tx_stkcost=case when stkqty=@stkeffect then stkcost else convert(numeric(20,2),stkcost/stkqty*@stkeffect) end
    from stkasset_hs with (nolock, index=stkasset_hs_pk)
   where stkcode=@stkcode and market=@market and custid=@custid and 
         stkqty>=@stkeffect and ltlx='01'

   -- ���г��۸���Ϊת��۸�����У�������Ŀǰ�ֲֳɱ���ƽ���۸�ת�롣
   if (@tx_stkcost is null)               
       begin
           select @stkprice=lastprice, @matchamt=lastprice*@stkeffect
             from stkprice with (nolock)
            where stkcode=@stkcode and market=@market and bizdate=@bizdate 

            if (@matchamt is null)
                begin
                    select @msg='�����¹�ȡ�۸���Ϣ����.'
                    raiserror(' %s', 12, 1, @msg) with SETERROR                       
                end
         end       
         
   if (@matchamt is null)  
       begin
          select @matchamt=@tx_stkcost
       end

begin tran

    -- ��ת������ͨ��
    exec @ret=nb_Cust_Stkasset_Commit
              @serverid=@serverid, @orgid=@orgid, @custid=@custid, @fundid=@fundid, @moneytype=@moneytype, @bankcode=@bankcode,
              @action='ZC', @market=@market, @stkcode=@stkcode, @ltlx='01', @matchqty=@matchqty, @matchamt=@matchamt,
              @matchamt_ex=0, @aiamount=0, @fundeffect=@fundeffect, @stkeffect=-@matchqty,
              @stkcost_ch=- @tx_stkcost * @matchqty / @stkqty, @syvalue_ch=@matchamt - @tx_stkcost * @matchqty / @stkqty,
              @aicost_ch=0, @lxsr_ch=0, @fee=0, @jsxf=0, @yhs=0,
              @ghf=0, @qtfee=0, @lxs=0, @blje=0, @blxx='', @msg=@msg output

     if (@ret!=0)
        begin
           raiserror(' %s', 12, 1, @msg) with SETERROR
        end

     -- ��ת����ͨ��
     exec @ret=nb_Cust_Stkasset_Commit
             @serverid=@serverid, @orgid=@orgid, @custid=@custid, @fundid=@fundid, @moneytype=@moneytype, @bankcode=@bankcode,
	     @action='ZR', @market=@market, @stkcode=@stkcode, @ltlx='00', @matchqty=@matchqty, @matchamt=@matchamt,
	     @matchamt_ex=0, @aiamount=0, @fundeffect=@fundeffect, @stkeffect=@stkeffect, @stkcost_ch=@matchamt, @syvalue_ch=0,
	     @aicost_ch=0, @lxsr_ch=0, @fee=0, @jsxf=0, @yhs=0, @ghf=0,
	     @qtfee=0, @lxs=0, @blje=0, @blxx='', @msg=@msg output

     if (@ret!=0)
        begin
           raiserror(' %s', 12, 1, @msg) with SETERROR
        end
              
      select @msg='���㴦��ɹ�'
      update logasset 
         set sett_status=3, sett_remark=@msg
       where sno=@sno and bizdate=@bizdate and serverid=@serverid

      commit tran
      return 0
end try

begin catch
   if @@trancount > 0
      rollback tran

   select @msg='ʧ��:'+error_message()+''
   update logasset_hs 
      set sett_status=4, sett_remark=@msg
    where sno=@sno and bizdate=@bizdate and serverid=@serverid

   return -1
end catch
go
