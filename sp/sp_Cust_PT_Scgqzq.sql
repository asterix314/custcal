/********************************************
    业务摘要：  110434
    业务名称：  删除过期证券
    动作代码：  -
    流通类型：  -
********************************************/
if exists (select * from sysobjects where type='P' and name= 'sp_Cust_PT_Scgqzq' )
    drop proc sp_Cust_PT_Scgqzq
go

CREATE proc sp_Cust_PT_Scgqzq(
 @serverid  char(1)      
,@bizdate   int          
,@sno       int
,@custid    bigint    
,@msg       varchar(128) =null output)
with encryption
as
-- do nothing
GO

