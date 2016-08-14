if exists(select * from sysobjects where xtype='U' and name='sysconfig')
   drop table sysconfig
go
create table sysconfig(
 iid        int           primary key
,cstep      varchar(32)   --����
,cstepname  varchar(64)   --��������
,iskey      char(1)       --�ؼ�����  0 �ǹؼ����� 1�ؼ�����
,threadnum  int           --�߳���    0 �洢���� 1-32 �߳���
,begtime    varchar(32)   --��ʼʱ��  yyyy-MM-dd HH:mm:ss
,endtime    varchar(32)   --����ʱ��  yyyy-MM-dd HH:mm:ss
,procticks  int           --ִ�к�ʱ  ����ms
,reccount   int           --��¼��
,status     char(1)       --״̬      0 δִ�� 1ִ�г��� 2�����
,remark     varchar(256)  --��ע
)
go   
insert sysconfig(iid, cstep, cstepname, iskey, threadnum, begtime, endtime, procticks, reccount, status, remark)
values(1, 20150101, '��һ������', 1, 0, '', '', 0, 1, 1, '-')
insert sysconfig(iid, cstep, cstepname, iskey, threadnum, begtime, endtime, procticks, reccount, status, remark)
values(2, 20150105, 'ϵͳ����', 1, 0, '', '', 0, 1, 1, '-')
insert sysconfig(iid, cstep, cstepname, iskey, threadnum, begtime, endtime, procticks, reccount, status, remark)
values(3, 'sp_sysinit', 'ϵͳ��ʼ��', 1, 0, '', '', 0, 0, 1, '')
insert sysconfig(iid, cstep, cstepname, iskey, threadnum, begtime, endtime, procticks, reccount, status, remark)
values(4, 'sp_JZ_cj', '���н��ײɼ�1', 1, 0, '', '', 0, 0, 0, '')
insert sysconfig(iid, cstep, cstepname, iskey, threadnum, begtime, endtime, procticks, reccount, status, remark)
values(5, 'sp_PrepareTrade', '����Ԥ����', 1, 0, '', '', 0, 0, 0, '')
insert sysconfig(iid, cstep, cstepname, iskey, threadnum, begtime, endtime, procticks, reccount, status, remark)
values(6, 'sp_SettleMain', '���㴦��', 1, 10, '', '', 0, 0, 0, '')
insert sysconfig(iid, cstep, cstepname, iskey, threadnum, begtime, endtime, procticks, reccount, status, remark)
values(7, 'sp_SettleGyjt', '��������Ϣ����', 1, 10, '', '', 0, 0, 0, '')
insert sysconfig(iid, cstep, cstepname, iskey, threadnum, begtime, endtime, procticks, reccount, status, remark)
values(8, 'sp_SettleCheck', '�ֲ����ʽ�˶�', 1, 0, '', '', 0, 0, 0, '')
insert sysconfig(iid, cstep, cstepname, iskey, threadnum, begtime, endtime, procticks, reccount, status, remark)
values(9, 'sp_DataSum', '���ݻ���', 1, 0, '', '', 0, 0, 0, '')
insert sysconfig(iid, cstep, cstepname, iskey, threadnum, begtime, endtime, procticks, reccount, status, remark)
values(10, 'sp_DataBack', '���ݹ鵵', 1, 0, '', '', 0, 0, 0, '')
go
if exists(select * from sysobjects where xtype='U' and name='stkasset_hs')
   drop table stkasset_hs
go
create table stkasset_hs(
 serverid       char(1)         --�ڵ�� 1-3,7,8
,orgid          varchar(4)      --Ӫҵ����
,custid         bigint          --�ͻ���
,fundid         bigint          --�ʽ��ʺ�
,market         char(1)         --�г� 0123-J6-8
,stkcode        varchar(10)     --֤ȯ����
,ltlx           varchar(2)      --��ͨ����  00��ͨ�� 01������ͨ 03�깺״̬ 06���ʻع� 07��ȯ�ع� 80��� 81�ղ� 
,stkbuyqty      numeric(20,2)   --��������(�����г��������ף�ͳ�ƿͻ���������)
,stkbuyamt      numeric(20,2)   --������
,stksaleqty     numeric(20,2)   --��������(�����г��������ף�ͳ�ƿͻ���������)
,stksaleamt     numeric(20,2)   --�������
,stkbuyamt_ex   numeric(20,2)   --����������*(�����뽻����ͳ��,�ǽ���������ETF�����ֽ������תծת���ʽ���Ȩ�ʽ�)
,stksaleamt_ex  numeric(20,2)   --�����������*(�����뽻����ͳ��,�ǽ��������)
,stkztgrqty     numeric(20,2)   --ת����������ת�й��룬ETF����ת�룬תծת���룬�ϲ�����룬ETF�Ϲ��룬����ת������
                                --��ָ�ڹ�˾�ڲ���ͬ�ʲ���ʽ��ת����������ⲿת����ʲ�   
,stkztgramt     numeric(20,2)   --ת�����֤ȯת��ʱ�ۺϵĽ���Ӱ���ʽ���
,stkztgcqty     numeric(20,2)   --ת����������ת�йܳ���ETF����ת����תծת�ɳ����ϲ���ֳ���ETF�Ϲ���������ת�����      
,stkztgcamt     numeric(20,2)   --ת������֤ȯת��ʱ�ۺϵĽ���Ӱ���ʽ���
                                --��ָ�ڹ�˾�ڲ���ͬ�ʲ���ʽ��ת�����������ⲿת�����ʲ�   
,stkhgqty       numeric(20,2)   --�������
,stkhlamt       numeric(20,2)   --�������
,stkpgqty       numeric(20,2)   --�������
,stkpgamt       numeric(20,2)   --��ɽ��
,stkqty         numeric(20,2)   --�������
,stkqty_ch      numeric(20,2)   --��������䶯
,stkqty_tz      numeric(20,2)   --�������������������ֺ쵽�ʺͳ�Ȩ��Ϣ��ͬ��ʱУ����ֵʱ��
,stkqty_tzje    numeric(20,2)   --���������������ֺ쵽�ʺͳ�Ȩ��Ϣ��ͬ��ʱУ����ֵʱ��  
,stkpledge      numeric(20,2)   --��Ѻ����
,stkdebt        numeric(20,2)   --��������
,stkloan        numeric(20,2)   --�������
,stkadjust      numeric(20,2)   --�ⲿת�н���Ҫ��¼���ҹ�˾�ʲ�֮���ת��ת��������������ʲ����ӻ���٣���ͬ������깺���˳�
                                --����ⲿת��֤ȯ����ֵ�����ⲿת�����ʲ�
,stkadjust_ch   numeric(20,2)   --�ⲿת�н��ձ䶯
,stkprice       numeric(9,4)    --�г��۸�
,bondintr       numeric(9,4)    --ծȯƱ����Ϣ
,mktvalue       numeric(20,2)   --��ֵ��=stkqty*stkprice=stkcost+gyvalue
,aiamount       numeric(20,2)   --Ԥ����Ϣ, =stkqty*bondintr=aicost+lxjt
,stkcost        numeric(20,2)   --����ɱ�������ʱ����������ʱ�����������ȱ����Ǽ�
,stkcost_ch     numeric(20,2)   --����ɱ��䶯
,aicost         numeric(20,2)   --��Ϣ�ɱ�������ʱ����������ʱ�����������ȱ����Ǽ�
,aicost_ch      numeric(20,2)   --��Ϣ�ɱ��䶯
,syvalue        numeric(20,2)   --Ͷ�����棬����ʱ�����������-̯���ɱ�����
,syvalue_ch     numeric(20,2)   --Ͷ������䶯
,lxsr           numeric(20,2)   --��Ϣ����(��Ϣ�ֺ�)���յ��ֺ���Ϣʱ��������ʱ����������Ϣ���-̯���ɱ�����
,lxsr_ch        numeric(20,2)   --��Ϣ����䶯
,gyvalue        numeric(20,2)   --����ӯ��,=mktvalue-stkcost
,gyvalue_ch     numeric(20,2)   --����ӯ���䶯
,lxjt           numeric(20,2)   --������Ϣ,=aiamount-aicost
,lxjt_ch        numeric(20,2)   --������Ϣ�䶯
,hglx           numeric(20,2)   --�ع���Ϣ        
,hglx_ch        numeric(20,2)   --�ع���Ϣ�䶯
,fee            numeric(20,2)   --����* fee=jsxf+ghf+qtfee
,fee_ch         numeric(20,2)   --���ñ䶯
,yhs            numeric(20,2)   --ӡ��˰*����fee����
,yhs_ch         numeric(20,2)   --ӡ��˰�䶯 
,lxs            numeric(20,2)   --��Ϣ˰*����fee��yhs����
,lxs_ch         numeric(20,2)   --��Ϣ˰�䶯
,jsxf           numeric(20,2)   --ȯ��Ӷ��        --ͳ���ã��Ѿ�����fee����
,jsxf_ch        numeric(20,2)   --ȯ��Ӷ��䶯
,ghf            numeric(20,2)   --������          --ͳ���ã��Ѿ�����fee����
,ghf_ch         numeric(20,2)   --�����ѱ䶯
,qtfee          numeric(20,2)   --������          --ͳ���ã��Ѿ�����fee����
,qtfee_ch       numeric(20,2)   --�����ѱ䶯
,jtdate         int             --��������
,gydate         int             --��������
,remark         varchar(128)    --��ע
constraint stkasset_hs_pk primary key nonclustered(stkcode, market, ltlx, fundid, custid, orgid, serverid)
)
go   
if exists(select * from sysobjects where xtype='U' and name='stkasset_hs_2015')
   drop table stkasset_hs_2015
go
create table stkasset_hs_2015(
 backdate       int             --��������
,serverid       char(1)         --�ڵ��
,orgid          varchar(4)      --Ӫҵ����
,custid         bigint          --�ͻ���
,fundid         bigint          --�ʽ��ʺţ�������
,market         char(1)         --�г�
,stkcode        varchar(10)     --֤ȯ����
,ltlx           varchar(2)      --��ͨ����  00��ͨ�� 01������ͨ 03�깺״̬ 06���ʻع� 07��ȯ�ع� 80��� 81�ղ� 
,stkbuyqty      numeric(20,2)   --��������(�����г��������ף�ͳ�ƿͻ���������)
,stkbuyamt      numeric(20,2)   --������
,stksaleqty     numeric(20,2)   --��������(�����г��������ף�ͳ�ƿͻ���������)
,stksaleamt     numeric(20,2)   --�������
,stkbuyamt_ex   numeric(20,2)   --����������*(�����뽻����ͳ��,�ǽ���������ETF�����ֽ������תծת���ʽ���Ȩ�ʽ�)
,stksaleamt_ex  numeric(20,2)   --�����������*(�����뽻����ͳ��,�ǽ��������)
,stkztgrqty     numeric(20,2)   --ת����������ת�й��룬ETF����ת�룬תծת���룬�ϲ�����룬ETF�Ϲ��룬����ת������
                                --��ָ�ڹ�˾�ڲ���ͬ�ʲ���ʽ��ת����������ⲿת����ʲ�   
,stkztgramt     numeric(20,2)   --ת�����֤ȯת��ʱ�ۺϵĽ���Ӱ���ʽ���
,stkztgcqty     numeric(20,2)   --ת����������ת�йܳ���ETF����ת����תծת�ɳ����ϲ���ֳ���ETF�Ϲ���������ת�����      
,stkztgcamt     numeric(20,2)   --ת������֤ȯת��ʱ�ۺϵĽ���Ӱ���ʽ���
                                --��ָ�ڹ�˾�ڲ���ͬ�ʲ���ʽ��ת�����������ⲿת�����ʲ�   
,stkhgqty       numeric(20,2)   --�������
,stkhlamt       numeric(20,2)   --�������
,stkpgqty       numeric(20,2)   --�������
,stkpgamt       numeric(20,2)   --��ɽ��
,stkqty         numeric(20,2)   --�������
,stkqty_ch      numeric(20,2)   --��������䶯
,stkqty_tz      numeric(20,2)   --�������������������ֺ쵽�ʺͳ�Ȩ��Ϣ��ͬ��ʱУ����ֵʱ��
,stkqty_tzje    numeric(20,2)   --���������������ֺ쵽�ʺͳ�Ȩ��Ϣ��ͬ��ʱУ����ֵʱ��  
,stkpledge      numeric(20,2)   --��Ѻ����
,stkdebt        numeric(20,2)   --��������
,stkloan        numeric(20,2)   --�������
,stkadjust      numeric(20,2)   --�ⲿת�н���Ҫ��¼���ҹ�˾�ʲ�֮���ת��ת��������������ʲ����ӻ���٣���ͬ������깺���˳�
                                --����ⲿת��֤ȯ����ֵ�����ⲿת�����ʲ�
,stkadjust_ch   numeric(20,2)   --�ⲿת�н��ձ䶯
,stkprice       numeric(9,4)    --�г��۸�
,bondintr       numeric(9,4)    --ծȯƱ����Ϣ
,mktvalue       numeric(20,2)   --��ֵ���
,aiamount       numeric(20,2)   --Ԥ����Ϣ
,stkcost        numeric(20,2)   --����ɱ�������ʱ����������ʱ�����������ȱ����Ǽ�
,stkcost_ch     numeric(20,2)   --����ɱ��䶯
,aicost         numeric(20,2)   --��Ϣ�ɱ�������ʱ����������ʱ�����������ȱ����Ǽ�
,aicost_ch      numeric(20,2)   --��Ϣ�ɱ��䶯
,syvalue        numeric(20,2)   --Ͷ�����棬����ʱ�����������-̯���ɱ�����
,syvalue_ch     numeric(20,2)   --Ͷ������䶯
,lxsr           numeric(20,2)   --��Ϣ����(��Ϣ�ֺ�)���յ��ֺ���Ϣʱ��������ʱ����������Ϣ���-̯���ɱ�����
,lxsr_ch        numeric(20,2)   --��Ϣ����䶯
,gyvalue        numeric(20,2)   --����ӯ��
,gyvalue_ch     numeric(20,2)   --����ӯ���䶯
,lxjt           numeric(20,2)   --������Ϣ
,lxjt_ch        numeric(20,2)   --������Ϣ�䶯
,hglx           numeric(20,2)   --�ع���Ϣ        
,hglx_ch        numeric(20,2)   --�ع���Ϣ�䶯
,fee            numeric(20,2)   --����* fee=jsxf+ghf+qtfee
,fee_ch         numeric(20,2)   --���ñ䶯
,yhs            numeric(20,2)   --ӡ��˰*����fee����
,yhs_ch         numeric(20,2)   --ӡ��˰�䶯 
,lxs            numeric(20,2)   --��Ϣ˰*����fee��yhs����
,lxs_ch         numeric(20,2)   --��Ϣ˰�䶯
,jsxf           numeric(20,2)   --ȯ��Ӷ��        --ͳ���ã��Ѿ�����fee����
,jsxf_ch        numeric(20,2)   --ȯ��Ӷ��䶯
,ghf            numeric(20,2)   --������          --ͳ���ã��Ѿ�����fee����
,ghf_ch         numeric(20,2)   --�����ѱ䶯
,qtfee          numeric(20,2)   --������          --ͳ���ã��Ѿ�����fee����
,qtfee_ch       numeric(20,2)   --�����ѱ䶯
,jtdate         int             --��������
,gydate         int             --��������
,remark         varchar(128)    --��ע
constraint stkasset_hs_2015_pk primary key nonclustered(stkcode, market, ltlx, fundid, custid, orgid, serverid, backdate)
)
go   
if exists(select * from sysobjects where xtype='U' and name='stkasset_hs_2016')
   drop table stkasset_hs_2016
go
create table stkasset_hs_2016(
 backdate       int             --��������
,serverid       char(1)         --�ڵ��
,orgid          varchar(4)      --Ӫҵ����
,custid         bigint          --�ͻ���
,fundid         bigint          --�ʽ��ʺţ�������
,market         char(1)         --�г�
,stkcode        varchar(10)     --֤ȯ����
,ltlx           varchar(2)      --��ͨ����  00��ͨ�� 01������ͨ 03�깺״̬ 06���ʻع� 07��ȯ�ع� 80��� 81�ղ� 
,stkbuyqty      numeric(20,2)   --��������(�����г��������ף�ͳ�ƿͻ���������)
,stkbuyamt      numeric(20,2)   --������
,stksaleqty     numeric(20,2)   --��������(�����г��������ף�ͳ�ƿͻ���������)
,stksaleamt     numeric(20,2)   --�������
,stkbuyamt_ex   numeric(20,2)   --����������*(�����뽻����ͳ��,�ǽ���������ETF�����ֽ������תծת���ʽ���Ȩ�ʽ�)
,stksaleamt_ex  numeric(20,2)   --�����������*(�����뽻����ͳ��,�ǽ��������)
,stkztgrqty     numeric(20,2)   --ת����������ת�й��룬ETF����ת�룬תծת���룬�ϲ�����룬ETF�Ϲ��룬����ת������
                                --��ָ�ڹ�˾�ڲ���ͬ�ʲ���ʽ��ת����������ⲿת����ʲ�   
,stkztgramt     numeric(20,2)   --ת�����֤ȯת��ʱ�ۺϵĽ���Ӱ���ʽ���
,stkztgcqty     numeric(20,2)   --ת����������ת�йܳ���ETF����ת����תծת�ɳ����ϲ���ֳ���ETF�Ϲ���������ת�����      
,stkztgcamt     numeric(20,2)   --ת������֤ȯת��ʱ�ۺϵĽ���Ӱ���ʽ���
                                --��ָ�ڹ�˾�ڲ���ͬ�ʲ���ʽ��ת�����������ⲿת�����ʲ�   
,stkhgqty       numeric(20,2)   --�������
,stkhlamt       numeric(20,2)   --�������
,stkpgqty       numeric(20,2)   --�������
,stkpgamt       numeric(20,2)   --��ɽ��
,stkqty         numeric(20,2)   --�������
,stkqty_ch      numeric(20,2)   --��������䶯
,stkqty_tz      numeric(20,2)   --�������������������ֺ쵽�ʺͳ�Ȩ��Ϣ��ͬ��ʱУ����ֵʱ��
,stkqty_tzje    numeric(20,2)   --���������������ֺ쵽�ʺͳ�Ȩ��Ϣ��ͬ��ʱУ����ֵʱ��  
,stkpledge      numeric(20,2)   --��Ѻ����
,stkdebt        numeric(20,2)   --��������
,stkloan        numeric(20,2)   --�������
,stkadjust      numeric(20,2)   --�ⲿת�н���Ҫ��¼���ҹ�˾�ʲ�֮���ת��ת��������������ʲ����ӻ���٣���ͬ������깺���˳�
                                --����ⲿת��֤ȯ����ֵ�����ⲿת�����ʲ�
,stkadjust_ch   numeric(20,2)   --�ⲿת�н��ձ䶯
,stkprice       numeric(9,4)    --�г��۸�
,bondintr       numeric(9,4)    --ծȯƱ����Ϣ
,mktvalue       numeric(20,2)   --��ֵ���
,aiamount       numeric(20,2)   --Ԥ����Ϣ
,stkcost        numeric(20,2)   --����ɱ�������ʱ����������ʱ�����������ȱ����Ǽ�
,stkcost_ch     numeric(20,2)   --����ɱ��䶯
,aicost         numeric(20,2)   --��Ϣ�ɱ�������ʱ����������ʱ�����������ȱ����Ǽ�
,aicost_ch      numeric(20,2)   --��Ϣ�ɱ��䶯
,syvalue        numeric(20,2)   --Ͷ�����棬����ʱ�����������-̯���ɱ�����
,syvalue_ch     numeric(20,2)   --Ͷ������䶯
,lxsr           numeric(20,2)   --��Ϣ����(��Ϣ�ֺ�)���յ��ֺ���Ϣʱ��������ʱ����������Ϣ���-̯���ɱ�����
,lxsr_ch        numeric(20,2)   --��Ϣ����䶯
,gyvalue        numeric(20,2)   --����ӯ��
,gyvalue_ch     numeric(20,2)   --����ӯ���䶯
,lxjt           numeric(20,2)   --������Ϣ
,lxjt_ch        numeric(20,2)   --������Ϣ�䶯
,hglx           numeric(20,2)   --�ع���Ϣ        
,hglx_ch        numeric(20,2)   --�ع���Ϣ�䶯
,fee            numeric(20,2)   --����* fee=jsxf+ghf+qtfee
,fee_ch         numeric(20,2)   --���ñ䶯
,yhs            numeric(20,2)   --ӡ��˰*����fee����
,yhs_ch         numeric(20,2)   --ӡ��˰�䶯 
,lxs            numeric(20,2)   --��Ϣ˰*����fee��yhs����
,lxs_ch         numeric(20,2)   --��Ϣ˰�䶯
,jsxf           numeric(20,2)   --ȯ��Ӷ��        --ͳ���ã��Ѿ�����fee����
,jsxf_ch        numeric(20,2)   --ȯ��Ӷ��䶯
,ghf            numeric(20,2)   --������          --ͳ���ã��Ѿ�����fee����
,ghf_ch         numeric(20,2)   --�����ѱ䶯
,qtfee          numeric(20,2)   --������          --ͳ���ã��Ѿ�����fee����
,qtfee_ch       numeric(20,2)   --�����ѱ䶯
,jtdate         int             --��������
,gydate         int             --��������
,remark         varchar(128)    --��ע
constraint stkasset_hs_2016_pk primary key nonclustered(stkcode, market, ltlx, fundid, custid, orgid, serverid, backdate)
)
go   
if exists(select * from sysobjects where xtype='U' and name='fundasset_hs')
   drop table fundasset_hs
go
create table fundasset_hs(
 serverid       char(1)
,orgid          varchar(4)      --Ӫҵ����
,custid         bigint          --�ͻ���
,fundid         bigint          --�ʽ��ʺţ�������
,moneytype      char(1)         --��������
,fundlastbal    numeric(20,2)   --�������
,fundbal        numeric(20,2)   --�������
,fundbal_ch     numeric(20,2)   --�������,���ձ䶯
,fundsave       numeric(20,2)   --�����
,fundsave_ch    numeric(20,2)   --�����,���ձ䶯
,fundunsave     numeric(20,2)   --ȡ����
,fundunsave_ch  numeric(20,2)   --ȡ����,���ձ䶯
,fundloan       numeric(20,2)   --������ 
,fundloan_ch    numeric(20,2)   --������,���ձ䶯 
,funddebt       numeric(20,2)   --������
,funddebt_ch    numeric(20,2)   --������,���ձ䶯
,funduncome     numeric(20,2)   --ҵ����;δ�ؽ��
,funduncome_ch  numeric(20,2)   --ҵ����;δ�ؽ��,���ձ䶯
,fundunpay      numeric(20,2)   --ҵ����;δ�����
,fundunpay_ch   numeric(20,2)   --ҵ����;δ�����,���ձ䶯
,fundadjust     numeric(20,2)   --�ⲿ�ʲ�����,�����ʽ�ת��ת�������ⲿת�йܣ�Ӱ������ݶ�ļ���
,fundadjust_ch  numeric(20,2)   --�ⲿ�ʲ�����,���ձ䶯
,fundintr       numeric(20,2)   --��Ϣ����
,fundintr_ch    numeric(20,2)   --��Ϣ���������ձ䶯
,fundaward      numeric(20,2)   --�ۼƽ�Ϣ
,fundaward_ch   numeric(20,2)   --�ۼƽ�Ϣ�����ձ䶯
,bankcode       varchar(4)      --Ӫҵ����
,mktvalue       numeric(20,2)   --����ֵ
,totalvalue     numeric(20,2)   --���ʲ�,mktvalue+fundbal+funduncome+fundloan-funddebt
,totalfe        numeric(20,2)   --�ܷݶ�,�����ʼ��,�������ݴ�ȡ��յ��յ�λ��ֵ������깺�����˳��ݶ�
,nav            numeric(12,6)   --��λ��ֵ,totalvalue/totalfe�������ʼ��Ϊ1�����ݾ�ֵ��������ӯ������
,tjdate         int             --ͳ������
,remark         varchar(64)     --��ע
constraint fundasset_hs_pk primary key nonclustered(fundid, custid, orgid, moneytype, bankcode, serverid)
)
go   
if exists(select * from sysobjects where xtype='U' and name='fundasset_hs_2015')
   drop table fundasset_hs_2015
go
create table fundasset_hs_2015(
 backdate       int
,serverid       char(1)
,orgid          varchar(4)      --Ӫҵ����
,custid         bigint          --�ͻ���
,fundid         bigint          --�ʽ��ʺţ�������
,moneytype      char(1)         --��������
,fundlastbal    numeric(20,2)   --�������
,fundbal        numeric(20,2)   --�������
,fundbal_ch     numeric(20,2)   --�������,���ձ䶯
,fundsave       numeric(20,2)   --�����
,fundsave_ch    numeric(20,2)   --�����,���ձ䶯
,fundunsave     numeric(20,2)   --ȡ����
,fundunsave_ch  numeric(20,2)   --ȡ����,���ձ䶯
,fundloan       numeric(20,2)   --������ 
,fundloan_ch    numeric(20,2)   --������,���ձ䶯 
,funddebt       numeric(20,2)   --������
,funddebt_ch    numeric(20,2)   --������,���ձ䶯
,funduncome     numeric(20,2)   --ҵ����;δ�ؽ��
,funduncome_ch  numeric(20,2)   --ҵ����;δ�ؽ��,���ձ䶯
,fundunpay      numeric(20,2)   --ҵ����;δ�����
,fundunpay_ch   numeric(20,2)   --ҵ����;δ�����,���ձ䶯
,fundadjust     numeric(20,2)   --�ⲿ�ʲ�����,�����ʽ�ת��ת�������ⲿת�йܣ�Ӱ������ݶ�ļ���
,fundadjust_ch  numeric(20,2)   --�ⲿ�ʲ�����,���ձ䶯
,fundintr       numeric(20,2)   --��Ϣ����
,fundintr_ch    numeric(20,2)   --��Ϣ���������ձ䶯
,fundaward      numeric(20,2)   --�ۼƽ�Ϣ
,fundaward_ch   numeric(20,2)   --�ۼƽ�Ϣ�����ձ䶯
,bankcode       varchar(4)      --Ӫҵ����
,mktvalue       numeric(20,2)   --����ֵ
,totalvalue     numeric(20,2)   --���ʲ�,mktvalue+fundbal+funduncome+fundloan-funddebt
,totalfe        numeric(20,2)   --�ܷݶ�,�����ʼ��,�������ݴ�ȡ��յ��յ�λ��ֵ������깺�����˳��ݶ�
,nav            numeric(12,6)   --��λ��ֵ,totalvalue/totalfe�������ʼ��Ϊ1�����ݾ�ֵ��������ӯ������
,tjdate         int             --ͳ������
,remark         varchar(64)     --��ע
constraint fundasset_hs_2015_pk primary key nonclustered(fundid, custid, orgid, moneytype, bankcode, backdate, serverid)
)
go   
if exists(select * from sysobjects where xtype='U' and name='logasset_hs')
   drop table logasset_hs
go
create table logasset_hs(
 serverid	    int	 
,bizdate	    int             --��������
,orderdate	    int             --��������
,sno	        int             --�������
,relativesno	int             --�������
,orgid	        char(4)         --������
,custid	        bigint          --�ͻ���
,fundid	        bigint          --�ʽ��˺�
,secuid	        varchar(32)     --֤ȯ�˺�
,moneytype	    char(1)         --��������
,digestid	    int             --ҵ��ժҪ
,market	        char(1)         --�г�����
,stkcode	    varchar(16)     --֤ȯ����
,bankcode	    char(4)         --���д���
,fundeffect	    numeric(20,2)   --�ʽ���
,fundbal	    numeric(20,2)   --�ʽ����
,stkeffect      numeric(20,2)   --�ɷݷ���
,stkbal         numeric(20,2)   --�ɷ���� 
,matchqty	    numeric(20,2)   --�ɽ�����
,matchamt	    numeric(20,2)   --�ɽ����
,orderid        varchar(10)     --ί�����
,matchprice     numeric(9,3)    --�ɽ��۸�
,fee_jsxf       numeric(20,2)   --������
,fee_sxf        numeric(20,2)   --��������
,fee_ghf        numeric(20,2)   --������
,fee_yhs        numeric(20,2)   --ӡ��˰
,feefront       numeric(20,2)   --ǰ̨��
,operway        char(1)         --������ʽ
,ordersno       int             --ί�к�
,remark         varchar(32)     --��ע
,bsflag         char(2)         --�������
,creditid       char(1)         --     
,creditflag     char(1)         --
,ref_sno        int             --�������
,ref_stkcode    varchar(16)     --��������
,busintype      int             --ҵ��ժҪ
,sett_status    char(1)         --����״̬
,sett_remark    varchar(128)    --���㱸ע
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
,bizdate	    int             --��������
,orderdate	    int             --��������
,sno	        int             --�������
,relativesno	int             --�������
,orgid	        char(4)         --������
,custid	        bigint          --�ͻ���
,fundid	        bigint          --�ʽ��˺�
,secuid	        varchar(32)     --֤ȯ�˺�
,moneytype	    char(1)         --��������
,digestid	    int             --ҵ��ժҪ
,market	        char(1)         --�г�����
,stkcode	    varchar(16)     --֤ȯ����
,bankcode	    char(4)         --���д���
,fundeffect	    numeric(20,2)   --�ʽ���
,fundbal	    numeric(20,2)   --�ʽ����
,stkeffect      numeric(20,2)   --�ɷݷ���
,stkbal         numeric(20,2)   --�ɷ���� 
,matchqty	    numeric(20,2)   --�ɽ�����
,matchamt	    numeric(20,2)   --�ɽ����
,orderid        varchar(10)     --ί�����
,matchprice     numeric(9,3)    --�ɽ��۸�
,fee_jsxf       numeric(20,2)   --������
,fee_sxf        numeric(20,2)   --��������
,fee_ghf        numeric(20,2)   --������
,fee_yhs        numeric(20,2)   --ӡ��˰
,feefront       numeric(20,2)   --ǰ̨��
,operway        char(1)         --������ʽ
,ordersno       int             --ί�к�
,remark         varchar(32)     --��ע
,bsflag         char(2)         --�������
,creditid       char(1)         --     
,creditflag     char(1)         --
,ref_sno        int             --�������
,ref_stkcode    varchar(16)     --��������
,busintype      int             --ҵ��ժҪ
,sett_status    char(1)         --����״̬
,sett_remark    varchar(128)    --���㱸ע
constraint logasset_hs_2015_pk primary key nonclustered(sno, bizdate, backdate, serverid)
)
go   
