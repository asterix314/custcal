/********************************************
    业务摘要：  222004
    业务名称：  投票确认
    动作代码：  -
    流通类型：  -
********************************************/
if exists (select * from sysobjects where type='P' and name= 'sp_Cust_PT_Tpqr' )
    drop proc sp_Cust_PT_Tpqr
go

CREATE proc sp_Cust_PT_Tpqr(
 @serverid  char(1)      
,@bizdate   int          
,@sno       int
,@custid    bigint    
,@msg       varchar(128) =null output)
with encryption
as
-- do nothing
GO

