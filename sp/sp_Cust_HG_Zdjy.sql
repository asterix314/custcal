/********************************************
    业务摘要：  220118
    业务名称：  港股通指定交易
    动作代码：  -
    流通类型：  -
********************************************/
if exists (select * from sysobjects where type='P' and name= 'sp_Cust_HG_Zdjy' )
    drop proc sp_Cust_HG_Zdjy
go

CREATE proc sp_Cust_HG_Zdjy(
 @serverid  char(1)      
,@bizdate   int          
,@sno       int
,@custid    bigint    
,@msg       varchar(128) =null output)
with encryption
as
-- do nothing
GO

