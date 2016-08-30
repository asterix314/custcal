if exists (select * from sysobjects where type='P' and name='nb_Cust_Stkasset_Commit')
    drop proc nb_Cust_Stkasset_Commit
go
/*过程：提交证券和资金表修改，不包含存取款等纯资金业务（纯资金业务需要自己处理资金的变动）
declare @msg as varchar(128)
exec nb_Cust_Stkasset_Commit 20150105, 1, 100, @msg output
select @msg
*/
create proc nb_Cust_Stkasset_Commit(
 @serverid       char(1)         --节点号   节点A:1-3 B股7 融资融券8
,@orgid          varchar(4)      --营业部号
,@custid         bigint          --客户号
,@fundid         bigint          --资金帐号，助记用
,@moneytype      char(1)         --货币代码，0人民币 1港币 2美元
,@bankcode       varchar(4)      --银行代码
,@action         varchar(3)      --动作类型--0B/0S买入/卖出     *买卖交易，一般会实际产生手续费
                                           --ZR/ZC内部转入/转出 *资产不同形式资产的转换，比如ETF股票换基金，可转债转换为股票等
                                           --WR/WC外部转入/转出 *资产向我公司之外转出或者从外部转入进来
                                           --HG/HL/PG红股红利/配股 
                                           --ZYR/ZYC质押入库/出库 
                                           --RR/RC证券融入/融出
                                           --EB/ES ETF申购/赎回 
,@market         char(1)         --市场代码  同集中交易字典 0深A 1沪A 2深B 3沪B 
,@stkcode        varchar(10)     --证券代码 
,@ltlx           varchar(2)      --流通类型--00流通股 *正常情况下一般都是00流通股，涉及到新股申购、未上市股份、融资融券、期货期权时才不为00
                                           --01限售流通 03申购状态 06融资回购 07融券回购 80多仓 81空仓 
,@matchqty       numeric(20,2)   --成交数量，股份实际成交数量或者转托管等的数量，用于统计数量，永远为正数
,@matchamt       numeric(20,2)   --成交金额，对应真实资金发生，一般指实际成交金额，或者ETF申购现金替代或债转股资金，净价金额，不包含债券利息，不包含费用
,@matchamt_ex    numeric(20,2)   --成交金额扩展，不对应真实资金发生，一般指证券替换类业务证券市值折算出的金额
                                 --例如ETF申购赎回或债券转股，证券转托管折算的金额，此字段用于统计金额，永远为正数
,@aiamount       numeric(20,2)   --债券票面金额，债券成交金额+债券票面金额=实际发生金额
,@fundeffect     numeric(20,2)   --*资金发生数，指实际资金发生数
,@stkeffect      numeric(20,2)   --*股份变动，股份实际变动数量，区别正负号
,@stkcost_ch     numeric(20,2)   --*成本金额，买入记增，卖出按实际数量摊销后记减
,@syvalue_ch     numeric(20,2)   --*投资收益，卖出或划出时，按照卖出金额减去摊销成本记增
,@aicost_ch      numeric(20,2)   --*利息成本，债券买入记增，卖出按实际数量摊销后记减
,@lxsr_ch        numeric(20,2)   --*利息收入，债券卖出或兑付兑息火划出时，按照卖出利息金额减去摊销利息成本记增 
                                 --注意，上述加*号的变量均区分正负号，其余不加*号的永远送非负数
,@fee            numeric(20,2)   --费用
,@jsxf           numeric(20,2)   --券商佣金(净手续费)
,@yhs            numeric(20,2)   --印花税
,@ghf            numeric(20,2)   --过户费
,@qtfee          numeric(20,2)   --其他费用
,@lxs            numeric(20,2)   --利息税
,@blje           numeric(20,2)   --保留数字字段（可用做数量或金额），保留用
,@blxx           varchar(30)     --保留文本字段（可用做文本类的输入补充），保留用
,@msg            varchar(64)     =null output
)
with encryption
as
declare @stkbuyqty as numeric(20,2), @stkbuyamt as numeric(20,2), @stksaleqty as numeric(20,2), @stksaleamt as numeric(20,2), 
        @stkbuyamt_ex as numeric(20,2), @stksaleamt_ex as numeric(20,2), @stkztgrqty as numeric(20,2), @stkztgramt as numeric(20,2),
        @stkztgcqty as numeric(20,2), @stkztgcamt as numeric(20,2), @stkhgqty as numeric(20,2), @stkhlamt as numeric(20,2), 
        @stkpgqty as numeric(20,2), @stkpgamt as numeric(20,2), @stkadjust as numeric(20,2), 
        @stkpledge as numeric(20,2), @stkdebt as numeric(20,2), @stkloan as numeric(20,2),
        @direction as int, @rowcount as int

 select @stkbuyqty=0, @stkbuyamt=0, @stksaleqty=0, @stksaleamt=0, @stkbuyamt_ex=0, @stksaleamt_ex=0, 
        @stkztgrqty=0, @stkztgramt=0, @stkztgcqty=0, @stkztgcamt=0, @stkhgqty=0, @stkhlamt=0, 
        @stkpgqty=0, @stkpgamt=0, @stkadjust=0, @stkpledge=0, @stkdebt=0, @stkloan=0
          
   --动作类型--0B/0S买入/卖出     *买卖交易，一般会实际产生手续费
             --ZR/ZC内部转入/转出 *资产不同形式资产的转换，比如ETF股票换基金，可转债转换为股票等
             --WR/WC外部转入/转出 *资产向我公司之外转出或者从外部转入进来
             --HG/PG红股红利/配股 
             --ZYR/ZYC质押入库/出库 
             --RR/RC证券融入/融出       
             --EB/ES ETF申购/赎回 
   if (@action in ('0B','ZR','WR','HG','HL','PG','WR','ZYR','RR', 'EB'))
       begin
          select @direction='1'    
       end
    else if (@action in ('0S','ZC','WC','ZYC','RC', 'ES'))
       begin
          select @direction='2'    
       end
    else   
       begin
          select @msg='动作类型(action='+@action+')不能识别.'       
          raiserror(' %s', 12, 2, @msg) with SETERROR          
       end
       
   if (@action='0B')        --0B买入
       begin
          select @stkbuyqty=@matchqty, @stkbuyamt=@matchamt
       end
    else if (@action='0S')  --0S卖出
       begin
          select @stksaleqty=@matchqty, @stksaleamt=@matchamt       
       end       
    else if (@action='ZR')  --ZR转入
       begin
          select @stkztgrqty=@matchqty, @stkztgramt=@matchamt_ex     --证券折算的用@matchamt_ex，实际资金买的用@matchamt
       end
    else if (@action='ZC')  --ZC转出
       begin
          select @stkztgcqty=@matchqty, @stkztgcamt=@matchamt_ex     --证券折算的用@matchamt_ex，实际资金买的用@matchamt
       end
    else if (@action='WR')  --外部转入/转出
       begin
          select @stkztgrqty=@matchqty, @stkztgramt=@matchamt_ex, @stkadjust=@matchamt_ex  
       end
    else if (@action='WC')  --外部转入/转出
       begin
          select @stkztgcqty=@matchqty, @stkztgcamt=@matchamt_ex, @stkadjust=-@matchamt_ex    
       end       
    else if (@action='HG')  --HG红股红利
       begin
          select @stkhgqty=@matchqty, @stkhlamt=@matchamt       
       end
    else if (@action='PG')  --PG配股
       begin
          select @stkpgqty=@matchqty, @stkpgamt=@matchamt       
       end
    else if (@action='EB')  --WR外部转入
       begin
          select @stkztgrqty=@matchqty, @stkztgramt=@matchamt_ex, @stkbuyamt_ex=@matchamt   --证券折算的用@matchamt_ex，实际资金买的用@matchamt
       end
    else if (@action='ES')  --EB ETF申购
       begin
          select @stkztgcqty=@matchqty, @stkztgcamt=@matchamt_ex, @stksaleamt_ex=@matchamt  --证券折算的用@matchamt_ex，实际资金买的用@matchamt
       end       
    else
       begin
          select @msg='动作类型(action'+@action+')不能识别.'       
          raiserror(' %s', 12, 2, @msg) with SETERROR          
       end       
       
   --流通类型--00流通股 *正常情况下一般都是00流通股，涉及到新股申购、未上市股份、融资融券、期货期权时才不为00
             --01限售流通 03申购状态 06融资回购 07融券回购 80多仓 81空仓      
   if (@ltlx not in ('00','01','03','06','07','80','81'))
       begin
          select @msg='流通类型(ltlx)不能识别.'       
          raiserror(' %s', 12, 2, @msg) with SETERROR          
       end
          
   if (@fee!=@jsxf+@ghf+@qtfee)
       begin
          select @msg='费用(fee)和明细不符.'       
          raiserror(' %s', 12, 2, @msg) with SETERROR          
       end
       
   if (@direction='1' and @fundeffect!=-(@matchamt+@fee+@yhs+@lxs))     
       begin
          select @msg='资金发生数校验不平(direction=1).'       
          raiserror(' %s', 12, 2, @msg) with SETERROR          
       end

   if (@direction='2' and @fundeffect!=@matchamt-@fee-@yhs-@lxs)    
       begin
          select @msg='资金发生数校验不平(direction=2).'       
          raiserror(' %s', 12, 2, @msg) with SETERROR          
       end
       
   if (@direction='1' and @stkeffect<0) or (@direction='2' and @stkeffect>0)     
       begin
          select @msg='证券方向和发生数不一致.'       
          raiserror(' %s', 12, 2, @msg) with SETERROR          
       end

   if (@direction='1' and @matchamt+@stkpgamt+@fee+@yhs+@lxs+@fundeffect!=0) 
       begin
          select @msg='资金发生数和分项汇总不平.'       
          raiserror(' %s', 12, 2, @msg) with SETERROR                  
       end

   if (@direction='1' and @matchamt+@stkpgamt+@fee+@yhs+@lxs+@fundeffect!=0) 
       begin
          select @msg='资金发生数和分项汇总不平.'       
          raiserror(' %s', 12, 2, @msg) with SETERROR                  
       end
   
   if (@direction='2' and @matchamt+@matchamt_ex+@stkcost_ch!=@syvalue_ch) 
       begin
          select @msg='卖出资金减摊销成本和实现盈亏不平.'       
          raiserror(' %s', 12, 2, @msg) with SETERROR                  
       end
       
   if (@direction='2' and @aiamount+@aicost_ch!=@lxsr_ch) 
       begin
          select @msg='利息(或红利)资金减摊销利息成本和利息收入不平.'       
          raiserror(' %s', 12, 2, @msg) with SETERROR                  
       end       
       
begin try
   if (@direction='1')               --买入类，不需要校验持仓，如果无则需新增记录
       begin
          update stkasset_hs
             set stkbuyqty=stkbuyqty+@stkbuyqty, stkbuyamt=stkbuyamt+@stkbuyamt, stkbuyamt_ex=stkbuyamt_ex+@stkbuyamt_ex,
                 stkztgrqty=stkztgrqty+@stkztgrqty, stkztgramt=stkztgramt+@stkztgramt,
                 stkhgqty=stkhgqty+@stkhgqty, stkhlamt=stkhlamt+@stkhlamt, 
                 stkpgqty=stkpgqty+@stkpgqty, stkpgamt=stkpgamt+@stkpgamt,
                 stkdebt=stkdebt+@stkdebt, stkloan=stkloan+@stkloan,
                 stkpledge=stkpledge+@stkpledge,
                 stkqty=stkqty+@stkeffect, stkqty_ch=stkqty_ch+@stkeffect, 
                 stkcost=stkcost+@stkcost_ch, stkcost_ch=stkcost_ch+@stkcost_ch, 
                 mktvalue=mktvalue+@stkcost_ch,
                 aicost=aicost+@aicost_ch, aicost_ch=aicost_ch+@aicost_ch,
                 fee=fee+@fee, fee_ch=fee_ch+@fee,
                 jsxf=jsxf+@jsxf, jsxf_ch=jsxf_ch+@jsxf,
                 yhs=yhs+@yhs, yhs_ch=yhs_ch+@yhs,
                 ghf=ghf+@ghf, ghf_ch=ghf_ch+@ghf, 
                 qtfee=qtfee+@qtfee, qtfee_ch=qtfee_ch+@qtfee
           where stkcode=@stkcode and market=@market and fundid=@fundid and custid=@custid and orgid=@orgid and 
                 ltlx=@ltlx and serverid=@serverid       
       end
    else if (@direction='2')         --卖出类，需要校验持仓
       begin
          update stkasset_hs
             set stksaleqty=stksaleqty+@stksaleqty, stksaleamt=stksaleamt+@stksaleamt, stksaleamt_ex=stksaleamt_ex+@stksaleamt_ex,
                 stkztgcqty=stkztgcqty+@stkztgcqty, stkztgcamt=stkztgcamt+@stkztgcamt,
                 stkdebt=stkdebt+@stkdebt, stkloan=stkloan+@stkloan,
                 stkpledge=stkpledge+@stkpledge,
                 stkqty=stkqty+@stkeffect, stkqty_ch=stkqty_ch+@stkeffect, 
                 stkcost=stkcost+@stkcost_ch, stkcost_ch=stkcost_ch+@stkcost_ch, 
                 mktvalue=mktvalue+@stkcost_ch,
                 aicost=aicost+@aicost_ch, aicost_ch=aicost_ch+@aicost_ch,
                 fee=fee+@fee, fee_ch=fee_ch+@fee,
                 jsxf=jsxf+@jsxf, jsxf_ch=jsxf_ch+@jsxf,
                 yhs=yhs+@yhs, yhs_ch=yhs_ch+@yhs,
                 ghf=ghf+@ghf, ghf_ch=ghf_ch+@ghf, 
                 qtfee=qtfee+@qtfee, qtfee_ch=qtfee_ch+@qtfee
           where stkcode=@stkcode and market=@market and fundid=@fundid and custid=@custid and orgid=@orgid and 
                 ltlx=@ltlx and stkqty+@stkeffect>=0 and serverid=@serverid       
       end

   select @rowcount=@@rowcount
       if (@rowcount=0 and @direction='2')
           begin
              select @msg='证券持仓不足或不存在.'       
              raiserror(' %s', 12, 2, @msg) with SETERROR                   
           end
        else if (@rowcount>1)    
           begin
              select @msg='更新证券持仓行数错误(rowcount='+CONVERT(varchar, @rowcount)+').'       
              raiserror(' %s', 12, 2, @msg) with SETERROR                   
           end
        else if (@rowcount=0 and @direction='1')
           begin
              insert stkasset_hs
                     (serverid, orgid, custid, fundid, market, stkcode, ltlx, 
                      stkbuyqty, stkbuyamt, stksaleqty, stksaleamt, stkbuyamt_ex, stksaleamt_ex, 
                      stkztgrqty, stkztgramt, stkztgcqty, stkztgcamt, stkhgqty, stkhlamt, 
                      stkpgqty, stkpgamt, stkqty, stkqty_ch, stkqty_tz, stkqty_tzje, 
                      stkpledge, stkdebt, stkloan, stkadjust, stkadjust_ch, 
                      stkprice, bondintr, mktvalue, aiamount, stkcost, stkcost_ch, 
                      aicost, aicost_ch, syvalue, syvalue_ch, lxsr, lxsr_ch, 
                      gyvalue, gyvalue_ch, lxjt, lxjt_ch, hglx, hglx_ch, 
                      fee, fee_ch, yhs, yhs_ch, lxs, lxs_ch, jsxf, jsxf_ch, 
                      ghf, ghf_ch, qtfee, qtfee_ch, 
                      jtdate, gydate, remark)
               select @serverid, @orgid, @custid, @fundid, @market, @stkcode, @ltlx, 
                      @stkbuyqty, @stkbuyamt, @stksaleqty, @stksaleamt, @stkbuyamt_ex, @stksaleamt_ex, 
                      @stkztgrqty, @stkztgramt, @stkztgcqty, @stkztgcamt, @stkhgqty, @stkhlamt, 
                      @stkpgqty, @stkpgamt, @stkeffect, @stkeffect, stkqty_tz=0, stkqty_tzje=0, 
                      stkpledge=@stkpledge, stkdebt=@stkdebt, stkloan=@stkloan, stkadjust=@stkadjust, stkadjust_ch=@stkadjust, 
                      stkprice=0, bondintr=0, mktvalue=@stkcost_ch, @aiamount, stkcost=@stkcost_ch, @stkcost_ch, 
                      aicost=@aicost_ch, @aicost_ch, syvalue=@syvalue_ch, @syvalue_ch, lxsr=@lxsr_ch, @lxsr_ch, 
                      gyvalue=0, gyvalue_ch=0, lxjt=0, lxjt_ch=0, hglx=0, hglx_ch=0, 
                      @fee, fee_ch=@fee, @yhs, yhs_ch=@yhs, @lxs, lxs_ch=@lxs, @jsxf, jsxf_ch=@jsxf, 
                      @ghf, ghf_ch=@ghf, @qtfee, qtfee_ch=@qtfee, 
                      jtdate=0, gydate=0, remark=''             
           end
           
   if (@fundeffect!=0)        
       begin
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
                             funduncome=0, funduncome_ch=0, fundunpay=0, fundunpay_ch=0, fundadjust=0, fundadjust_ch=0, fundintr=0, fundintr_ch=0, 
                             fundaward=0, fundaward_ch=0, @bankcode, mktvalue=0, totalvalue=0, totalfe=0, nav=0, tjdate=0, remark=''     
                  end
       end

   select @msg='写资券资产记录成功.'
   return 0
end try
begin catch
   select @msg='写资券资产记录错误:('+LEFT(ERROR_MESSAGE(),22)+')'
   return -1
end catch
go
