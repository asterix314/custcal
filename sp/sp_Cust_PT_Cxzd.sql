/********************************************
    业务摘要：  220033
    业务名称：  撤销指定
    动作代码：  -
    流通类型：  -
********************************************/
if exists (select * from sysobjects where type='P' and name= 'sp_Cust_PT_Cxzd' )
    drop proc sp_Cust_PT_Cxzd
go

CREATE proc sp_Cust_PT_Cxzd(
 @serverid  char(1)      
,@bizdate   int          
,@sno       int
,@custid    bigint    
,@msg       varchar(128) =null output)
with encryption
as
-- do nothing
GO

