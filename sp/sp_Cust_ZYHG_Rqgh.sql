/********************************************
    ҵ��ժҪ��  221035
    ҵ�����ƣ�  ��ȯ����
    �������룺  RC
    ��ͨ���ͣ�  07
********************************************/
if exists (select * from sysobjects where type='P' and name='sp_Cust_ZYHG_Rqgh')
    drop proc sp_Cust_ZYHG_Rqgh
go
/*
declare @msg as varchar(128)
exec sp_Cust_ZYHG_Rqgh 20150105, 1, 100, @msg output
select @msg
*/
CREATE proc sp_Cust_ZYHG_Rqgh(
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
        @sett_remark as varchar(128)
declare @rowcount as int, @expense as numeric(20,2), @ret as int
        
 select @orgid=orgid, @fundid=fundid, @moneytype=moneytype, @digestid=digestid, @market=market, @stkcode=stkcode,
        @bankcode=bankcode, @fundeffect=fundeffect, @stkeffect=stkeffect, @matchqty=matchqty, @matchamt=matchamt,
        @fee_sxf=fee_sxf, @fee_jsxf=fee_jsxf, @fee_ghf=fee_ghf, @fee_yhs=fee_yhs, @feefront=feefront,
        @sett_status=sett_status, @sett_remark=sett_remark, @expense=fee_sxf + fee_ghs + fee_yhs + feefront
   from logasset with (nolock, index=index_of_logasset_pk)
  where sno=@sno and bizdate=@bizdate and serverid=@serverid and digestid=221035

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

    if (@fundeffect <= 0)
       begin
          select @msg='�ʽ������ҵ�񲻷�.'
          raiserror(' %s', 12, 1, @msg) with SETERROR
       end

    if (@matchqty <= 0)
       begin
          select @msg='�ɽ������������ҵ�񲻷�.'
          raiserror(' %s', 12, 1, @msg) with SETERROR
       end

    if (@expense != 0 or @fundeffect != @matchamt)
       begin
          select @msg='��ҵ����ò���.'
          raiserror(' %s', 12, 1, @msg) with SETERROR
       end

begin tran
    exec @ret=nb_Cust_Stkasset_Commit
              @serverid=@serverid, @orgid=@orgid, @custid=@custid, @fundid=@fundid, @moneytype=@moneytype, @bankcode=@bankcode,
              @action='RC', @market=@market, @stkcode=@stkcode, @ltlx='07', @matchqty=@matchqty, @matchamt=@matchamt,
              @matchamt_ex=0, @aiamount=0, @fundeffect=@fundeffect, @stkeffect=-@matchqty, @stkcost_ch=@matchamt, @syvalue_ch=0,
              @aicost_ch=0, @lxsr_ch=0, @fee=@fee_sxf + @fee_ghf + @feefront, @jsxf=@fee_jsxf, @yhs=@fee_yhs, @ghf=@fee_ghf,
              @qtfee=@feefront, @lxs=0, @blje=0, @blxx='', @msg=@msg output

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

   select @msg='ʧ��:' + error_message() + '' 
   update logasset_hs 
      set sett_status=4, sett_remark=@msg
    where sno=@sno and bizdate=@bizdate and serverid=@serverid

   return -1
end catch
go
