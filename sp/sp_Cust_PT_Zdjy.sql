/********************************************
    业务摘要：  220032
    业务名称：  指定交易
    动作代码：  -
    流通类型：  -
********************************************/
if exists (select * from sysobjects where type='P' and name= 'sp_Cust_PT_Zdjy' )
    drop proc sp_Cust_PT_Zdjy
go

CREATE proc sp_Cust_PT_Zdjy(
 @serverid  char(1)      
,@bizdate   int          
,@sno       int
,@custid    bigint    
,@msg       varchar(128) =null output)
with encryption
as
-- do nothing
GO

