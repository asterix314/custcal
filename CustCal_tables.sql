if exists(select * from sysobjects where xtype='U' and name='sysconfig')
   drop table sysconfig
go
create table sysconfig(
 iid        int           primary key
,cstep      varchar(32)   --步骤
,cstepname  varchar(64)   --步骤名称
,iskey      char(1)       --关键步骤  0 非关键步骤 1关键步骤
,threadnum  int           --线程数    0 存储过程 1-32 线程数
,begtime    varchar(32)   --开始时间  yyyy-MM-dd HH:mm:ss
,endtime    varchar(32)   --结束时间  yyyy-MM-dd HH:mm:ss
,procticks  int           --执行耗时  毫秒ms
,reccount   int           --记录数
,status     char(1)       --状态      0 未执行 1执行出错 2已完成
,remark     varchar(256)  --备注
)
go   
insert sysconfig(iid, cstep, cstepname, iskey, threadnum, begtime, endtime, procticks, reccount, status, remark)
values(1, 20150101, '上一交易日', 1, 0, '', '', 0, 1, 1, '-')
insert sysconfig(iid, cstep, cstepname, iskey, threadnum, begtime, endtime, procticks, reccount, status, remark)
values(2, 20150105, '系统日期', 1, 0, '', '', 0, 1, 1, '-')
insert sysconfig(iid, cstep, cstepname, iskey, threadnum, begtime, endtime, procticks, reccount, status, remark)
values(3, 'sp_sysinit', '系统初始化', 1, 0, '', '', 0, 0, 1, '')
insert sysconfig(iid, cstep, cstepname, iskey, threadnum, begtime, endtime, procticks, reccount, status, remark)
values(4, 'sp_JZ_cj', '集中交易采集1', 1, 0, '', '', 0, 0, 0, '')
insert sysconfig(iid, cstep, cstepname, iskey, threadnum, begtime, endtime, procticks, reccount, status, remark)
values(5, 'sp_PrepareTrade', '数据预处理', 1, 0, '', '', 0, 0, 0, '')
insert sysconfig(iid, cstep, cstepname, iskey, threadnum, begtime, endtime, procticks, reccount, status, remark)
values(6, 'sp_SettleMain', '核算处理', 1, 10, '', '', 0, 0, 0, '')
insert sysconfig(iid, cstep, cstepname, iskey, threadnum, begtime, endtime, procticks, reccount, status, remark)
values(7, 'sp_SettleGyjt', '公允与利息处理', 1, 10, '', '', 0, 0, 0, '')
insert sysconfig(iid, cstep, cstepname, iskey, threadnum, begtime, endtime, procticks, reccount, status, remark)
values(8, 'sp_SettleCheck', '持仓与资金核对', 1, 0, '', '', 0, 0, 0, '')
insert sysconfig(iid, cstep, cstepname, iskey, threadnum, begtime, endtime, procticks, reccount, status, remark)
values(9, 'sp_DataSum', '数据汇总', 1, 0, '', '', 0, 0, 0, '')
insert sysconfig(iid, cstep, cstepname, iskey, threadnum, begtime, endtime, procticks, reccount, status, remark)
values(10, 'sp_DataBack', '数据归档', 1, 0, '', '', 0, 0, 0, '')
go
if exists(select * from sysobjects where xtype='U' and name='stkasset_hs')
   drop table stkasset_hs
go
create table stkasset_hs(
 serverid       char(1)         --节点号 1-3,7,8
,orgid          varchar(4)      --营业部号
,custid         bigint          --客户号
,fundid         bigint          --资金帐号
,market         char(1)         --市场 0123-J6-8
,stkcode        varchar(10)     --证券代码
,ltlx           varchar(2)      --流通类型  00流通股 01限售流通 03申购状态 06融资回购 07融券回购 80多仓 81空仓 
,stkbuyqty      numeric(20,2)   --买入数量(二级市场买卖交易，统计客户交易量用)
,stkbuyamt      numeric(20,2)   --买入金额
,stksaleqty     numeric(20,2)   --卖出数量(二级市场买卖交易，统计客户交易量用)
,stksaleamt     numeric(20,2)   --卖出金额
,stkbuyamt_ex   numeric(20,2)   --其他买入金额*(不参与交易量统计,非交易量金额，如ETF申赎现金替代、转债转股资金、行权资金)
,stksaleamt_ex  numeric(20,2)   --其他卖出金额*(不参与交易量统计,非交易量金额)
,stkztgrqty     numeric(20,2)   --转入数量，含转托管入，ETF申赎转入，转债转股入，合并拆分入，ETF认购入，其他转换类入
                                --是指在公司内部不同资产形式的转换，区别从外部转入的资产   
,stkztgramt     numeric(20,2)   --转入金额，是证券转入时折合的金额，不影响资金发生
,stkztgcqty     numeric(20,2)   --转出数量，含转托管出，ETF申赎转出，转债转股出，合并拆分出，ETF认购出，其他转换类出      
,stkztgcamt     numeric(20,2)   --转出金额，是证券转出时折合的金额，不影响资金发生
                                --是指在公司内部不同资产形式的转换，区别向外部转出的资产   
,stkhgqty       numeric(20,2)   --红股数量
,stkhlamt       numeric(20,2)   --红利金额
,stkpgqty       numeric(20,2)   --配股数量
,stkpgamt       numeric(20,2)   --配股金额
,stkqty         numeric(20,2)   --库存数量
,stkqty_ch      numeric(20,2)   --库存数量变动
,stkqty_tz      numeric(20,2)   --调整数量，可正负，分红到帐和除权除息不同步时校正市值时用
,stkqty_tzje    numeric(20,2)   --调整金额，可正负，分红到帐和除权除息不同步时校正市值时用  
,stkpledge      numeric(20,2)   --质押数量
,stkdebt        numeric(20,2)   --借入数量
,stkloan        numeric(20,2)   --借出数量
,stkadjust      numeric(20,2)   --外部转托金额，主要记录非我公司资产之间的转入转出，此项引起的资产增加或减少，视同基金的申购或退出
                                --如从外部转入证券的市值或向外部转出的资产
,stkadjust_ch   numeric(20,2)   --外部转托金额当日变动
,stkprice       numeric(9,4)    --市场价格
,bondintr       numeric(9,4)    --债券票面利息
,mktvalue       numeric(20,2)   --市值金额，=stkqty*stkprice=stkcost+gyvalue
,aiamount       numeric(20,2)   --预计利息, =stkqty*bondintr=aicost+lxjt
,stkcost        numeric(20,2)   --买入成本，买入时记增，卖出时按卖出数量等比例记减
,stkcost_ch     numeric(20,2)   --买入成本变动
,aicost         numeric(20,2)   --利息成本，买入时记增，卖出时按卖出数量等比例记减
,aicost_ch      numeric(20,2)   --利息成本变动
,syvalue        numeric(20,2)   --投资收益，卖出时按照卖出金额-摊销成本记增
,syvalue_ch     numeric(20,2)   --投资收益变动
,lxsr           numeric(20,2)   --利息收入(股息分红)，收到分红或兑息时或者卖出时按照卖出利息金额-摊销成本记增
,lxsr_ch        numeric(20,2)   --利息收入变动
,gyvalue        numeric(20,2)   --浮动盈亏,=mktvalue-stkcost
,gyvalue_ch     numeric(20,2)   --浮动盈亏变动
,lxjt           numeric(20,2)   --计提利息,=aiamount-aicost
,lxjt_ch        numeric(20,2)   --计提利息变动
,hglx           numeric(20,2)   --回购利息        
,hglx_ch        numeric(20,2)   --回购利息变动
,fee            numeric(20,2)   --费用* fee=jsxf+ghf+qtfee
,fee_ch         numeric(20,2)   --费用变动
,yhs            numeric(20,2)   --印花税*，和fee单列
,yhs_ch         numeric(20,2)   --印花税变动 
,lxs            numeric(20,2)   --利息税*，和fee，yhs单列
,lxs_ch         numeric(20,2)   --利息税变动
,jsxf           numeric(20,2)   --券商佣金        --统计用，已经含在fee里面
,jsxf_ch        numeric(20,2)   --券商佣金变动
,ghf            numeric(20,2)   --过户费          --统计用，已经含在fee里面
,ghf_ch         numeric(20,2)   --过户费变动
,qtfee          numeric(20,2)   --其他费          --统计用，已经含在fee里面
,qtfee_ch       numeric(20,2)   --其他费变动
,jtdate         int             --计提日期
,gydate         int             --公允日期
,remark         varchar(128)    --备注
constraint stkasset_hs_pk primary key nonclustered(stkcode, market, ltlx, fundid, custid, orgid, serverid)
)
go   
if exists(select * from sysobjects where xtype='U' and name='stkasset_hs_2015')
   drop table stkasset_hs_2015
go
create table stkasset_hs_2015(
 backdate       int             --备份日期
,serverid       char(1)         --节点号
,orgid          varchar(4)      --营业部号
,custid         bigint          --客户号
,fundid         bigint          --资金帐号，助记用
,market         char(1)         --市场
,stkcode        varchar(10)     --证券代码
,ltlx           varchar(2)      --流通类型  00流通股 01限售流通 03申购状态 06融资回购 07融券回购 80多仓 81空仓 
,stkbuyqty      numeric(20,2)   --买入数量(二级市场买卖交易，统计客户交易量用)
,stkbuyamt      numeric(20,2)   --买入金额
,stksaleqty     numeric(20,2)   --卖出数量(二级市场买卖交易，统计客户交易量用)
,stksaleamt     numeric(20,2)   --卖出金额
,stkbuyamt_ex   numeric(20,2)   --其他买入金额*(不参与交易量统计,非交易量金额，如ETF申赎现金替代、转债转股资金、行权资金)
,stksaleamt_ex  numeric(20,2)   --其他卖出金额*(不参与交易量统计,非交易量金额)
,stkztgrqty     numeric(20,2)   --转入数量，含转托管入，ETF申赎转入，转债转股入，合并拆分入，ETF认购入，其他转换类入
                                --是指在公司内部不同资产形式的转换，区别从外部转入的资产   
,stkztgramt     numeric(20,2)   --转入金额，是证券转入时折合的金额，不影响资金发生
,stkztgcqty     numeric(20,2)   --转出数量，含转托管出，ETF申赎转出，转债转股出，合并拆分出，ETF认购出，其他转换类出      
,stkztgcamt     numeric(20,2)   --转出金额，是证券转出时折合的金额，不影响资金发生
                                --是指在公司内部不同资产形式的转换，区别向外部转出的资产   
,stkhgqty       numeric(20,2)   --红股数量
,stkhlamt       numeric(20,2)   --红利金额
,stkpgqty       numeric(20,2)   --配股数量
,stkpgamt       numeric(20,2)   --配股金额
,stkqty         numeric(20,2)   --库存数量
,stkqty_ch      numeric(20,2)   --库存数量变动
,stkqty_tz      numeric(20,2)   --调整数量，可正负，分红到帐和除权除息不同步时校正市值时用
,stkqty_tzje    numeric(20,2)   --调整金额，可正负，分红到帐和除权除息不同步时校正市值时用  
,stkpledge      numeric(20,2)   --质押数量
,stkdebt        numeric(20,2)   --借入数量
,stkloan        numeric(20,2)   --借出数量
,stkadjust      numeric(20,2)   --外部转托金额，主要记录非我公司资产之间的转入转出，此项引起的资产增加或减少，视同基金的申购或退出
                                --如从外部转入证券的市值或向外部转出的资产
,stkadjust_ch   numeric(20,2)   --外部转托金额当日变动
,stkprice       numeric(9,4)    --市场价格
,bondintr       numeric(9,4)    --债券票面利息
,mktvalue       numeric(20,2)   --市值金额
,aiamount       numeric(20,2)   --预计利息
,stkcost        numeric(20,2)   --买入成本，买入时记增，卖出时按卖出数量等比例记减
,stkcost_ch     numeric(20,2)   --买入成本变动
,aicost         numeric(20,2)   --利息成本，买入时记增，卖出时按卖出数量等比例记减
,aicost_ch      numeric(20,2)   --利息成本变动
,syvalue        numeric(20,2)   --投资收益，卖出时按照卖出金额-摊销成本记增
,syvalue_ch     numeric(20,2)   --投资收益变动
,lxsr           numeric(20,2)   --利息收入(股息分红)，收到分红或兑息时或者卖出时按照卖出利息金额-摊销成本记增
,lxsr_ch        numeric(20,2)   --利息收入变动
,gyvalue        numeric(20,2)   --浮动盈亏
,gyvalue_ch     numeric(20,2)   --浮动盈亏变动
,lxjt           numeric(20,2)   --计提利息
,lxjt_ch        numeric(20,2)   --计提利息变动
,hglx           numeric(20,2)   --回购利息        
,hglx_ch        numeric(20,2)   --回购利息变动
,fee            numeric(20,2)   --费用* fee=jsxf+ghf+qtfee
,fee_ch         numeric(20,2)   --费用变动
,yhs            numeric(20,2)   --印花税*，和fee单列
,yhs_ch         numeric(20,2)   --印花税变动 
,lxs            numeric(20,2)   --利息税*，和fee，yhs单列
,lxs_ch         numeric(20,2)   --利息税变动
,jsxf           numeric(20,2)   --券商佣金        --统计用，已经含在fee里面
,jsxf_ch        numeric(20,2)   --券商佣金变动
,ghf            numeric(20,2)   --过户费          --统计用，已经含在fee里面
,ghf_ch         numeric(20,2)   --过户费变动
,qtfee          numeric(20,2)   --其他费          --统计用，已经含在fee里面
,qtfee_ch       numeric(20,2)   --其他费变动
,jtdate         int             --计提日期
,gydate         int             --公允日期
,remark         varchar(128)    --备注
constraint stkasset_hs_2015_pk primary key nonclustered(stkcode, market, ltlx, fundid, custid, orgid, serverid, backdate)
)
go   
if exists(select * from sysobjects where xtype='U' and name='stkasset_hs_2016')
   drop table stkasset_hs_2016
go
create table stkasset_hs_2016(
 backdate       int             --备份日期
,serverid       char(1)         --节点号
,orgid          varchar(4)      --营业部号
,custid         bigint          --客户号
,fundid         bigint          --资金帐号，助记用
,market         char(1)         --市场
,stkcode        varchar(10)     --证券代码
,ltlx           varchar(2)      --流通类型  00流通股 01限售流通 03申购状态 06融资回购 07融券回购 80多仓 81空仓 
,stkbuyqty      numeric(20,2)   --买入数量(二级市场买卖交易，统计客户交易量用)
,stkbuyamt      numeric(20,2)   --买入金额
,stksaleqty     numeric(20,2)   --卖出数量(二级市场买卖交易，统计客户交易量用)
,stksaleamt     numeric(20,2)   --卖出金额
,stkbuyamt_ex   numeric(20,2)   --其他买入金额*(不参与交易量统计,非交易量金额，如ETF申赎现金替代、转债转股资金、行权资金)
,stksaleamt_ex  numeric(20,2)   --其他卖出金额*(不参与交易量统计,非交易量金额)
,stkztgrqty     numeric(20,2)   --转入数量，含转托管入，ETF申赎转入，转债转股入，合并拆分入，ETF认购入，其他转换类入
                                --是指在公司内部不同资产形式的转换，区别从外部转入的资产   
,stkztgramt     numeric(20,2)   --转入金额，是证券转入时折合的金额，不影响资金发生
,stkztgcqty     numeric(20,2)   --转出数量，含转托管出，ETF申赎转出，转债转股出，合并拆分出，ETF认购出，其他转换类出      
,stkztgcamt     numeric(20,2)   --转出金额，是证券转出时折合的金额，不影响资金发生
                                --是指在公司内部不同资产形式的转换，区别向外部转出的资产   
,stkhgqty       numeric(20,2)   --红股数量
,stkhlamt       numeric(20,2)   --红利金额
,stkpgqty       numeric(20,2)   --配股数量
,stkpgamt       numeric(20,2)   --配股金额
,stkqty         numeric(20,2)   --库存数量
,stkqty_ch      numeric(20,2)   --库存数量变动
,stkqty_tz      numeric(20,2)   --调整数量，可正负，分红到帐和除权除息不同步时校正市值时用
,stkqty_tzje    numeric(20,2)   --调整金额，可正负，分红到帐和除权除息不同步时校正市值时用  
,stkpledge      numeric(20,2)   --质押数量
,stkdebt        numeric(20,2)   --借入数量
,stkloan        numeric(20,2)   --借出数量
,stkadjust      numeric(20,2)   --外部转托金额，主要记录非我公司资产之间的转入转出，此项引起的资产增加或减少，视同基金的申购或退出
                                --如从外部转入证券的市值或向外部转出的资产
,stkadjust_ch   numeric(20,2)   --外部转托金额当日变动
,stkprice       numeric(9,4)    --市场价格
,bondintr       numeric(9,4)    --债券票面利息
,mktvalue       numeric(20,2)   --市值金额
,aiamount       numeric(20,2)   --预计利息
,stkcost        numeric(20,2)   --买入成本，买入时记增，卖出时按卖出数量等比例记减
,stkcost_ch     numeric(20,2)   --买入成本变动
,aicost         numeric(20,2)   --利息成本，买入时记增，卖出时按卖出数量等比例记减
,aicost_ch      numeric(20,2)   --利息成本变动
,syvalue        numeric(20,2)   --投资收益，卖出时按照卖出金额-摊销成本记增
,syvalue_ch     numeric(20,2)   --投资收益变动
,lxsr           numeric(20,2)   --利息收入(股息分红)，收到分红或兑息时或者卖出时按照卖出利息金额-摊销成本记增
,lxsr_ch        numeric(20,2)   --利息收入变动
,gyvalue        numeric(20,2)   --浮动盈亏
,gyvalue_ch     numeric(20,2)   --浮动盈亏变动
,lxjt           numeric(20,2)   --计提利息
,lxjt_ch        numeric(20,2)   --计提利息变动
,hglx           numeric(20,2)   --回购利息        
,hglx_ch        numeric(20,2)   --回购利息变动
,fee            numeric(20,2)   --费用* fee=jsxf+ghf+qtfee
,fee_ch         numeric(20,2)   --费用变动
,yhs            numeric(20,2)   --印花税*，和fee单列
,yhs_ch         numeric(20,2)   --印花税变动 
,lxs            numeric(20,2)   --利息税*，和fee，yhs单列
,lxs_ch         numeric(20,2)   --利息税变动
,jsxf           numeric(20,2)   --券商佣金        --统计用，已经含在fee里面
,jsxf_ch        numeric(20,2)   --券商佣金变动
,ghf            numeric(20,2)   --过户费          --统计用，已经含在fee里面
,ghf_ch         numeric(20,2)   --过户费变动
,qtfee          numeric(20,2)   --其他费          --统计用，已经含在fee里面
,qtfee_ch       numeric(20,2)   --其他费变动
,jtdate         int             --计提日期
,gydate         int             --公允日期
,remark         varchar(128)    --备注
constraint stkasset_hs_2016_pk primary key nonclustered(stkcode, market, ltlx, fundid, custid, orgid, serverid, backdate)
)
go   
if exists(select * from sysobjects where xtype='U' and name='fundasset_hs')
   drop table fundasset_hs
go
create table fundasset_hs(
 serverid       char(1)
,orgid          varchar(4)      --营业部号
,custid         bigint          --客户号
,fundid         bigint          --资金帐号，助记用
,moneytype      char(1)         --货币类型
,fundlastbal    numeric(20,2)   --上日余额
,fundbal        numeric(20,2)   --本日余额
,fundbal_ch     numeric(20,2)   --本日余额,当日变动
,fundsave       numeric(20,2)   --存款金额
,fundsave_ch    numeric(20,2)   --存款金额,当日变动
,fundunsave     numeric(20,2)   --取款金额
,fundunsave_ch  numeric(20,2)   --取款金额,当日变动
,fundloan       numeric(20,2)   --借出金额 
,fundloan_ch    numeric(20,2)   --借出金额,当日变动 
,funddebt       numeric(20,2)   --借入金额
,funddebt_ch    numeric(20,2)   --借入金额,当日变动
,funduncome     numeric(20,2)   --业务在途未回金额
,funduncome_ch  numeric(20,2)   --业务在途未回金额,当日变动
,fundunpay      numeric(20,2)   --业务在途未付金额
,fundunpay_ch   numeric(20,2)   --业务在途未付金额,当日变动
,fundadjust     numeric(20,2)   --外部资产增减,包括资金转入转出或者外部转托管，影响折算份额的计算
,fundadjust_ch  numeric(20,2)   --外部资产增减,当日变动
,fundintr       numeric(20,2)   --利息积数
,fundintr_ch    numeric(20,2)   --利息积数，当日变动
,fundaward      numeric(20,2)   --累计结息
,fundaward_ch   numeric(20,2)   --累计结息，当日变动
,bankcode       varchar(4)      --营业部号
,mktvalue       numeric(20,2)   --总市值
,totalvalue     numeric(20,2)   --总资产,mktvalue+fundbal+funduncome+fundloan-funddebt
,totalfe        numeric(20,2)   --总份额,年初初始化,后续根据存取款按照当日单位净值折算成申购或者退出份额
,nav            numeric(12,6)   --单位净值,totalvalue/totalfe，年初初始化为1，根据净值增减评判盈利能力
,tjdate         int             --统计日期
,remark         varchar(64)     --备注
constraint fundasset_hs_pk primary key nonclustered(fundid, custid, orgid, moneytype, bankcode, serverid)
)
go   
if exists(select * from sysobjects where xtype='U' and name='fundasset_hs_2015')
   drop table fundasset_hs_2015
go
create table fundasset_hs_2015(
 backdate       int
,serverid       char(1)
,orgid          varchar(4)      --营业部号
,custid         bigint          --客户号
,fundid         bigint          --资金帐号，助记用
,moneytype      char(1)         --货币类型
,fundlastbal    numeric(20,2)   --上日余额
,fundbal        numeric(20,2)   --本日余额
,fundbal_ch     numeric(20,2)   --本日余额,当日变动
,fundsave       numeric(20,2)   --存款金额
,fundsave_ch    numeric(20,2)   --存款金额,当日变动
,fundunsave     numeric(20,2)   --取款金额
,fundunsave_ch  numeric(20,2)   --取款金额,当日变动
,fundloan       numeric(20,2)   --借出金额 
,fundloan_ch    numeric(20,2)   --借出金额,当日变动 
,funddebt       numeric(20,2)   --借入金额
,funddebt_ch    numeric(20,2)   --借入金额,当日变动
,funduncome     numeric(20,2)   --业务在途未回金额
,funduncome_ch  numeric(20,2)   --业务在途未回金额,当日变动
,fundunpay      numeric(20,2)   --业务在途未付金额
,fundunpay_ch   numeric(20,2)   --业务在途未付金额,当日变动
,fundadjust     numeric(20,2)   --外部资产增减,包括资金转入转出或者外部转托管，影响折算份额的计算
,fundadjust_ch  numeric(20,2)   --外部资产增减,当日变动
,fundintr       numeric(20,2)   --利息积数
,fundintr_ch    numeric(20,2)   --利息积数，当日变动
,fundaward      numeric(20,2)   --累计结息
,fundaward_ch   numeric(20,2)   --累计结息，当日变动
,bankcode       varchar(4)      --营业部号
,mktvalue       numeric(20,2)   --总市值
,totalvalue     numeric(20,2)   --总资产,mktvalue+fundbal+funduncome+fundloan-funddebt
,totalfe        numeric(20,2)   --总份额,年初初始化,后续根据存取款按照当日单位净值折算成申购或者退出份额
,nav            numeric(12,6)   --单位净值,totalvalue/totalfe，年初初始化为1，根据净值增减评判盈利能力
,tjdate         int             --统计日期
,remark         varchar(64)     --备注
constraint fundasset_hs_2015_pk primary key nonclustered(fundid, custid, orgid, moneytype, bankcode, backdate, serverid)
)
go   
if exists(select * from sysobjects where xtype='U' and name='logasset_hs')
   drop table logasset_hs
go
create table logasset_hs(
 serverid	    int	 
,bizdate	    int             --交收日期
,orderdate	    int             --交易日期
,sno	        int             --交易序号
,relativesno	int             --关联序号
,orgid	        char(4)         --机构号
,custid	        bigint          --客户号
,fundid	        bigint          --资金账号
,secuid	        varchar(32)     --证券账号
,moneytype	    char(1)         --货币类型
,digestid	    int             --业务摘要
,market	        char(1)         --市场代码
,stkcode	    varchar(16)     --证券代码
,bankcode	    char(4)         --银行代码
,fundeffect	    numeric(20,2)   --资金发生
,fundbal	    numeric(20,2)   --资金余额
,stkeffect      numeric(20,2)   --股份发生
,stkbal         numeric(20,2)   --股份余额 
,matchqty	    numeric(20,2)   --成交数量
,matchamt	    numeric(20,2)   --成交金额
,orderid        varchar(10)     --委托序号
,matchprice     numeric(9,3)    --成交价格
,fee_jsxf       numeric(20,2)   --手续费
,fee_sxf        numeric(20,2)   --净手续费
,fee_ghf        numeric(20,2)   --过户费
,fee_yhs        numeric(20,2)   --印花税
,feefront       numeric(20,2)   --前台费
,operway        char(1)         --操作方式
,ordersno       int             --委托号
,remark         varchar(32)     --备注
,bsflag         char(2)         --买卖类别
,creditid       char(1)         --     
,creditflag     char(1)         --
,ref_sno        int             --关联序号
,ref_stkcode    varchar(16)     --关联代码
,busintype      int             --业务摘要
,sett_status    char(1)         --核算状态
,sett_remark    varchar(128)    --核算备注
constraint logasset_hs_pk primary key nonclustered(sno, bizdate, serverid)
)
go   
create index index_of_logasset_hs_custid on logasset_hs(custid, orgid, bizdate)
go
if exists(select * from sysobjects where xtype='U' and name='logasset_hs_2015')
   drop table logasset_hs_2015
go
create table logasset_hs_2015(
 backdate       int
,serverid	    int	 
,bizdate	    int             --交收日期
,orderdate	    int             --交易日期
,sno	        int             --交易序号
,relativesno	int             --关联序号
,orgid	        char(4)         --机构号
,custid	        bigint          --客户号
,fundid	        bigint          --资金账号
,secuid	        varchar(32)     --证券账号
,moneytype	    char(1)         --货币类型
,digestid	    int             --业务摘要
,market	        char(1)         --市场代码
,stkcode	    varchar(16)     --证券代码
,bankcode	    char(4)         --银行代码
,fundeffect	    numeric(20,2)   --资金发生
,fundbal	    numeric(20,2)   --资金余额
,stkeffect      numeric(20,2)   --股份发生
,stkbal         numeric(20,2)   --股份余额 
,matchqty	    numeric(20,2)   --成交数量
,matchamt	    numeric(20,2)   --成交金额
,orderid        varchar(10)     --委托序号
,matchprice     numeric(9,3)    --成交价格
,fee_jsxf       numeric(20,2)   --手续费
,fee_sxf        numeric(20,2)   --净手续费
,fee_ghf        numeric(20,2)   --过户费
,fee_yhs        numeric(20,2)   --印花税
,feefront       numeric(20,2)   --前台费
,operway        char(1)         --操作方式
,ordersno       int             --委托号
,remark         varchar(32)     --备注
,bsflag         char(2)         --买卖类别
,creditid       char(1)         --     
,creditflag     char(1)         --
,ref_sno        int             --关联序号
,ref_stkcode    varchar(16)     --关联代码
,busintype      int             --业务摘要
,sett_status    char(1)         --核算状态
,sett_remark    varchar(128)    --核算备注
constraint logasset_hs_2015_pk primary key nonclustered(sno, bizdate, backdate, serverid)
)
go   
