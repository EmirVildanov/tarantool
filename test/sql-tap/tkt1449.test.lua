#!/usr/bin/env tarantool
local test = require("sqltester")
test:plan(3)

--!./tcltestrunner.lua
-- 2005 September 19
--
-- The author disclaims copyright to this source code.  In place of
-- a legal notice, here is a blessing:
--
--    May you do good and not evil.
--    May you find forgiveness for yourself and forgive others.
--    May you share freely, never taking more than you give.
--
-------------------------------------------------------------------------
-- This file implements regression tests for sql library.
--
-- This file implements tests to verify that ticket #1449 has been
-- fixed.  
--
-- ["set","testdir",[["file","dirname",["argv0"]]]]
-- ["source",[["testdir"],"\/tester.tcl"]]
-- Somewhere in tkt1449-1.1 is a VIEW definition that uses a subquery and
-- a compound SELECT. So we cannot run this file if any of these features
-- are not available.


-- The following schema generated problems in ticket #1449.  We've retained
-- the original schema here because it is some unbelievably complex, it seemed
-- like a good test case for sql.
--
test:do_execsql_test(
    "tkt1449-1.1",
    [[
        -- Tarantool: DDL is prohibited inside a transaction so far
        -- START TRANSACTION;
        CREATE TABLE ACLS(ISSUEID varchar(50) not null, OBJECTID varchar(50) not null, PARTICIPANTID varchar(50) not null, PERMISSIONBITS int not null, constraint PK_ACLS primary key (ISSUEID, OBJECTID, PARTICIPANTID));
        CREATE TABLE ACTIONITEMSTATUSES(CLASSID int null, SEQNO int not null, LASTMODONNODEID varchar(50) not null, PREVMODONNODEID varchar(50) null, ISSUEID varchar(50) not null, OBJECTID varchar(50) not null, REVISIONNUM int not null, CONTAINERID varchar(50) not null, AUTHORID varchar(50) not null, CREATIONDATE varchar(25) null, LASTMODIFIEDDATE varchar(25) null, UPDATENUMBER int null, PREVREVISIONNUM int null, LASTCMD int null, LASTCMDACLVERSION int null, USERDEFINEDFIELD varchar(300) null, LASTMODIFIEDBYID varchar(50) null, FRIENDLYNAME varchar(100) not null, REVISION int not null, SHORTNAME varchar(30) not null, LONGNAME varchar(200) not null, ATTACHMENTHANDLING int not null, RESULT int not null, NOTIFYCREATOR varchar(1) null, NOTIFYASSIGNEE varchar(1) null, NOTIFYFYI varchar(1) null, NOTIFYCLOSURETEAM varchar(1) null, NOTIFYCOORDINATORS varchar(1) null, COMMENTREQUIRED varchar(1) not null, constraint PK_ACTIONITEMSTATUSES primary key (ISSUEID, OBJECTID));
        CREATE TABLE ACTIONITEMTYPES(CLASSID int null, SEQNO int not null, LASTMODONNODEID varchar(50) not null, PREVMODONNODEID varchar(50) null, ISSUEID varchar(50) not null, OBJECTID varchar(50) not null, REVISIONNUM int not null, CONTAINERID varchar(50) not null, AUTHORID varchar(50) not null, CREATIONDATE varchar(25) null, LASTMODIFIEDDATE varchar(25) null, UPDATENUMBER int null, PREVREVISIONNUM int null, LASTCMD int null, LASTCMDACLVERSION int null, USERDEFINEDFIELD varchar(300) null, LASTMODIFIEDBYID varchar(50) null, REVISION int not null, LABEL varchar(200) not null, INSTRUCTIONS text not null, EMAILINSTRUCTIONS text null, ALLOWEDSTATUSES text not null, INITIALSTATUS varchar(100) not null, COMMENTREQUIRED varchar(1) not null, ATTACHMENTHANDLING int not null, constraint PK_ACTIONITEMTYPES primary key (ISSUEID, OBJECTID));
        CREATE TABLE ATTACHMENTS(TQUNID varchar(36) not null, OBJECTID varchar(50) null, ISSUEID varchar(50) null, DATASTREAM SCALAR not null, CONTENTENCODING varchar(50) null, CONTENTCHARSET varchar(50) null, CONTENTTYPE varchar(100) null, CONTENTID varchar(100) null, CONTENTLOCATION varchar(100) null, CONTENTNAME varchar(100) not null, constraint PK_ATTACHMENTS primary key (TQUNID));
        CREATE TABLE COMPLIANCEPOLICIES(CLASSID int null, SEQNO int not null, LASTMODONNODEID varchar(50) not null, PREVMODONNODEID varchar(50) null, ISSUEID varchar(50) not null, OBJECTID varchar(50) not null, REVISIONNUM int not null, CONTAINERID varchar(50) not null, AUTHORID varchar(50) not null, CREATIONDATE varchar(25) null, LASTMODIFIEDDATE varchar(25) null, UPDATENUMBER int null, PREVREVISIONNUM int null, LASTCMD int null, LASTCMDACLVERSION int null, USERDEFINEDFIELD varchar(300) null, LASTMODIFIEDBYID varchar(50) null, BODY text null, constraint PK_COMPLIANCEPOLICIES primary key (ISSUEID, OBJECTID));
        CREATE TABLE DBHISTORY(id INT primary key, "DATETIME" varchar(25) not null, OPERATION varchar(20) not null, KUBIVERSION varchar(100) not null, FROMVERSION int null, TOVERSION int null);
        CREATE TABLE DBINFO(id INT primary key, FINGERPRINT varchar(32) not null, VERSION int not null);
        CREATE TABLE DETACHEDATTACHMENTS (TQUNID varchar(36) not null, ISSUEID varchar(50) not null, OBJECTID varchar(50) not null, PATH varchar(300) not null, DETACHEDFILELASTMODTIMESTAMP varchar(25) null, CONTENTID varchar(100) not null, constraint PK_DETACHEDATTACHMENTS primary key (TQUNID));
        CREATE TABLE DOCREFERENCES(CLASSID int null, SEQNO int not null, LASTMODONNODEID varchar(50) not null, PREVMODONNODEID varchar(50) null, ISSUEID varchar(50) not null, OBJECTID varchar(50) not null, REVISIONNUM int not null, CONTAINERID varchar(50) not null, AUTHORID varchar(50) not null, CREATIONDATE varchar(25) null, LASTMODIFIEDDATE varchar(25) null, UPDATENUMBER int null, PREVREVISIONNUM int null, LASTCMD int null, LASTCMDACLVERSION int null, USERDEFINEDFIELD varchar(300) null, LASTMODIFIEDBYID varchar(50) null, REFERENCEDOCUMENTID varchar(50) null, constraint PK_DOCREFERENCES primary key (ISSUEID, OBJECTID));
        CREATE TABLE DQ (TQUNID varchar(36) not null, ISSUEID varchar(50) not null, DEPENDSID varchar(50) null, DEPENDSTYPE int null, DEPENDSCOMMANDSTREAM SCALAR null, DEPENDSNODEIDSEQNOKEY varchar(100) null, DEPENDSACLVERSION int null, constraint PK_DQ primary key (TQUNID));
        CREATE TABLE EMAILQ(id INT primary key, TIMEQUEUED int not null, NODEID varchar(50) not null, MIME SCALAR not null, TQUNID varchar(36) not null);
        CREATE TABLE ENTERPRISEDATA(CLASSID int null, SEQNO int not null, LASTMODONNODEID varchar(50) not null, PREVMODONNODEID varchar(50) null, ISSUEID varchar(50) not null, OBJECTID varchar(50) not null, REVISIONNUM int not null, CONTAINERID varchar(50) not null, AUTHORID varchar(50) not null, CREATIONDATE varchar(25) null, LASTMODIFIEDDATE varchar(25) null, UPDATENUMBER int null, PREVREVISIONNUM int null, LASTCMD int null, LASTCMDACLVERSION int null, USERDEFINEDFIELD varchar(300) null, LASTMODIFIEDBYID varchar(50) null, DATE1 varchar(25) null, DATE2 varchar(25) null, DATE3 varchar(25) null, DATE4 varchar(25) null, DATE5 varchar(25) null, DATE6 varchar(25) null, DATE7 varchar(25) null, DATE8 varchar(25) null, DATE9 varchar(25) null, DATE10 varchar(25) null, VALUE1 int null, VALUE2 int null, VALUE3 int null, VALUE4 int null, VALUE5 int null, VALUE6 int null, VALUE7 int null, VALUE8 int null, VALUE9 int null, VALUE10 int null, VALUE11 int null, VALUE12 int null, VALUE13 int null, VALUE14 int null, VALUE15 int null, VALUE16 int null, VALUE17 int null, VALUE18 int null, VALUE19 int null, VALUE20 int null, STRING1 varchar(300) null, STRING2 varchar(300) null, STRING3 varchar(300) null, STRING4 varchar(300) null, STRING5 varchar(300) null, STRING6 varchar(300) null, STRING7 varchar(300) null, STRING8 varchar(300) null, STRING9 varchar(300) null, STRING10 varchar(300) null, LONGSTRING1 text null, LONGSTRING2 text null, LONGSTRING3 text null, LONGSTRING4 text null, LONGSTRING5 text null, LONGSTRING6 text null, LONGSTRING7 text null, LONGSTRING8 text null, LONGSTRING9 text null, LONGSTRING10 text null, constraint PK_ENTERPRISEDATA primary key (ISSUEID, OBJECTID));
        CREATE TABLE FILEMORGUE(TQUNID varchar(36) not null, PATH varchar(300) not null, DELETEFOLDERWHENEMPTY varchar(1) null, constraint PK_FILEMORGUE primary key (TQUNID));
        CREATE TABLE FILES(CLASSID int null, SEQNO int not null, LASTMODONNODEID varchar(50) not null, PREVMODONNODEID varchar(50) null, ISSUEID varchar(50) not null, OBJECTID varchar(50) not null, REVISIONNUM int not null, CONTAINERID varchar(50) not null, AUTHORID varchar(50) not null, CREATIONDATE varchar(25) null, LASTMODIFIEDDATE varchar(25) null, UPDATENUMBER int null, PREVREVISIONNUM int null, LASTCMD int null, LASTCMDACLVERSION int null, USERDEFINEDFIELD varchar(300) null, LASTMODIFIEDBYID varchar(50) null, PARENTENTITYID varchar(50) null, BODY text null, BODYCONTENTTYPE varchar(100) null, ISOBSOLETE varchar(1) null, FILENAME varchar(300) not null, VISIBLENAME varchar(300) not null, VERSIONSTRING varchar(300) not null, DOCUMENTHASH varchar(40) not null, ISFINAL varchar(1) null, DOCREFERENCEID varchar(50) not null, constraint PK_FILES primary key (ISSUEID, OBJECTID));
        CREATE TABLE FOLDERS(CLASSID int null, SEQNO int not null, LASTMODONNODEID varchar(50) not null, PREVMODONNODEID varchar(50) null, ISSUEID varchar(50) not null, OBJECTID varchar(50) not null, REVISIONNUM int not null, CONTAINERID varchar(50) not null, AUTHORID varchar(50) not null, CREATIONDATE varchar(25) null, LASTMODIFIEDDATE varchar(25) null, UPDATENUMBER int null, PREVREVISIONNUM int null, LASTCMD int null, LASTCMDACLVERSION int null, USERDEFINEDFIELD varchar(300) null, LASTMODIFIEDBYID varchar(50) null, CONTAINERNAME varchar(300) null, CONTAINERACLSETTINGS text null, constraint PK_FOLDERS primary key (ISSUEID, OBJECTID));
        CREATE TABLE GLOBALSETTINGS(CLASSID int null, SEQNO int not null, LASTMODONNODEID varchar(50) not null, PREVMODONNODEID varchar(50) null, ISSUEID varchar(50) not null, OBJECTID varchar(50) not null, REVISIONNUM int not null, CONTAINERID varchar(50) not null, AUTHORID varchar(50) not null, CREATIONDATE varchar(25) null, LASTMODIFIEDDATE varchar(25) null, UPDATENUMBER int null, PREVREVISIONNUM int null, LASTCMD int null, LASTCMDACLVERSION int null, USERDEFINEDFIELD varchar(300) null, LASTMODIFIEDBYID varchar(50) null, SINGULARPROJECTLABEL varchar(30) not null, PLURALPROJECTLABEL varchar(30) not null, PROJECTREQUIRED varchar(1) not null, CUSTOMPROJECTSALLOWED varchar(1) not null, ACTIONITEMSPECXML text null, PROJECTLISTXML text null, ENTERPRISEDATALABELS text null, ENTERPRISEDATATABXSL text null, constraint PK_GLOBALSETTINGS primary key (ISSUEID, OBJECTID));
        CREATE TABLE GLOBALSTRINGPROPERTIES(ID int not null, VALUE varchar(300) not null, constraint PK_GLOBALSTRINGPROPERTIES primary key (ID));
        CREATE TABLE IMQ(TQUNID varchar(36) not null, DATETIMEQUEUED varchar(25) not null, ISSUEID varchar(50) not null, KUBIBUILD varchar(30) not null, FAILCOUNT int not null, LASTRUN varchar(25) null, ENVELOPESTREAM SCALAR not null, PAYLOADSTREAM SCALAR not null, constraint PK_IMQ primary key (TQUNID));
        CREATE TABLE INVITATIONNODES(INVITATIONID varchar(50) not null, RECIPIENTNODEID varchar(50) not null, DATECREATED varchar(25) not null, constraint PK_INVITATIONNODES primary key (INVITATIONID, RECIPIENTNODEID));
        CREATE TABLE INVITATIONS (id INT primary key, INVITATIONID varchar(50) not null, SENDERNODEID varchar(50) not null, RECIPIENTEMAILADDR varchar(200) not null, RECIPIENTUSERID varchar(50) null, RECIPIENTNODES text null, ISSUEID varchar(50) not null, ENVELOPE text not null, MESSAGEBLOB SCALAR not null, INVITATIONSTATE int not null, TQUNID varchar(36) not null, DATECREATED varchar(25) not null);
        CREATE TABLE ISSUES (CLASSID int null, SEQNO int not null, LASTMODONNODEID varchar(50) not null, PREVMODONNODEID varchar(50) null, ISSUEID varchar(50) not null, OBJECTID varchar(50) not null, REVISIONNUM int not null, CONTAINERID varchar(50) not null, AUTHORID varchar(50) not null, CREATIONDATE varchar(25) null, LASTMODIFIEDDATE varchar(25) null, UPDATENUMBER int null, PREVREVISIONNUM int null, LASTCMD int null, LASTCMDACLVERSION int null, USERDEFINEDFIELD varchar(300) null, LASTMODIFIEDBYID varchar(50) null, CONTAINERNAME varchar(300) null, CONTAINERACLSETTINGS text null, ISINITIALIZED varchar(1) null, BLINDINVITES text null, ISSYSTEMISSUE varchar(1) not null, ISSUETYPE int not null, ACTIVITYTYPEID varchar(50) null, ISINCOMPLETE varchar(1) not null, constraint PK_ISSUES primary key (ISSUEID, OBJECTID));
        CREATE TABLE ISSUESETTINGS (CLASSID int null, SEQNO int not null, LASTMODONNODEID varchar(50) not null, PREVMODONNODEID varchar(50) null, ISSUEID varchar(50) not null, OBJECTID varchar(50) not null, REVISIONNUM int not null, CONTAINERID varchar(50) not null, AUTHORID varchar(50) not null, CREATIONDATE varchar(25) null, LASTMODIFIEDDATE varchar(25) null, UPDATENUMBER int null, PREVREVISIONNUM int null, LASTCMD int null, LASTCMDACLVERSION int null, USERDEFINEDFIELD varchar(300) null, LASTMODIFIEDBYID varchar(50) null, ISSUENAME varchar(300) not null, ISSUEACLSETTINGS text not null, ISSUEDUEDATE varchar(25) null, ISSUEPRIORITY int null, ISSUESTATUS int null, DESCRIPTION text null, PROJECTID varchar(100) null, PROJECTNAME text null, PROJECTNAMEISCUSTOM varchar(1) null, ISSYSTEMISSUE varchar(1) not null, ACTIONITEMREVNUM int not null, constraint PK_ISSUESETTINGS primary key (ISSUEID, OBJECTID));
        CREATE TABLE KMTPMSG (MSGID integer not null, SENDERID varchar(50) null, RECIPIENTIDLIST text not null, ISSUEID varchar(50) null, MESSAGETYPE int not null, ENVELOPE text null, MESSAGEBLOB SCALAR not null, RECEIVEDDATE varchar(25) not null, constraint PK_KMTPMSG primary key (MSGID));
        CREATE TABLE KMTPNODEQ(id INT primary key, NODEID varchar(50) not null, MSGID int not null, RECEIVEDDATE varchar(25) not null, SENDCOUNT int not null);
        CREATE TABLE KMTPQ(MSGID integer not null, SENDERID varchar(50) null, RECIPIENTIDLIST text not null, ISSUEID varchar(50) null, MESSAGETYPE int not null, ENVELOPE text null, MESSAGEBLOB SCALAR not null, constraint PK_KMTPQ primary key (MSGID));
        CREATE TABLE LOGENTRIES(CLASSID int null, SEQNO int not null, LASTMODONNODEID varchar(50) not null, PREVMODONNODEID varchar(50) null, ISSUEID varchar(50) not null, OBJECTID varchar(50) not null, REVISIONNUM int not null, CONTAINERID varchar(50) not null, AUTHORID varchar(50) not null, CREATIONDATE varchar(25) null, LASTMODIFIEDDATE varchar(25) null, UPDATENUMBER int null, PREVREVISIONNUM int null, LASTCMD int null, LASTCMDACLVERSION int null, USERDEFINEDFIELD varchar(300) null, LASTMODIFIEDBYID varchar(50) null, PARENTENTITYID varchar(50) null, BODY text null, BODYCONTENTTYPE varchar(100) null, ISOBSOLETE varchar(1) null, ACTIONTYPE int not null, ASSOCIATEDOBJECTIDS text null, OLDENTITIES text null, NEWENTITIES text null, OTHERENTITIES text null, constraint PK_LOGENTRIES primary key (ISSUEID, OBJECTID));
        CREATE TABLE LSBI(TQUNID varchar(36) not null, ISSUEID varchar(50) not null, TABLEITEMID varchar(50) null, TABLENODEID varchar(50) null, TABLECMD int null, TABLECONTAINERID varchar(50) null, TABLESEQNO int null, DIRTYCONTENT text null, STUBBED varchar(1) null, ENTITYSTUBDATA text null, UPDATENUMBER int not null, constraint PK_LSBI primary key (TQUNID));
        CREATE TABLE LSBN(TQUNID varchar(36) not null, ISSUEID varchar(50) not null, NODEID varchar(50) not null, STORESEQNO int not null, SYNCSEQNO int not null, LASTMSGDATE varchar(25) null, constraint PK_LSBN primary key (TQUNID));
        CREATE TABLE MMQ(TQUNID varchar(36) not null, ISSUEID varchar(50) not null, TABLEREQUESTNODE varchar(50) null, MMQENTRYINDEX varchar(60) null, DIRECTION int null, NODEID varchar(50) null, TABLEFIRSTSEQNO int null, TABLELASTSEQNO int null, NEXTRESENDTIMEOUT varchar(25) null, TABLETIMEOUTMULTIPLIER int null, constraint PK_MMQ primary key (TQUNID));
        CREATE TABLE NODEREG(id INT primary key, NODEID varchar(50) not null, USERID varchar(50) null, CREATETIME varchar(25) not null, TQUNID varchar(36) not null);
        CREATE TABLE NODES (id INT primary key, NODEID varchar(50) not null, USERID varchar(50) null, NODESTATE int not null, NODECERT text null, KUBIVERSION int not null, KUBIBUILD varchar(30) not null, TQUNID varchar(36) not null, LASTBINDDATE varchar(25) null, LASTUNBINDDATE varchar(25) null, LASTBINDIP varchar(15) null, NUMBINDS int not null, NUMSENDS int not null, NUMPOLLS int not null, NUMRECVS int not null);
        CREATE TABLE PARTICIPANTNODES(id INT primary key, ISSUEID varchar(50) not null, OBJECTID varchar(50) not null, NODEID varchar(50) not null, USERID varchar(50) null, NODESTATE int not null, NODECERT text null, KUBIVERSION int not null, KUBIBUILD varchar(30) not null, TQUNID varchar(36) not null);
        CREATE TABLE PARTICIPANTS(CLASSID int null, SEQNO int not null, LASTMODONNODEID varchar(50) not null, PREVMODONNODEID varchar(50) null, ISSUEID varchar(50) not null, OBJECTID varchar(50) not null, REVISIONNUM int not null, CONTAINERID varchar(50) not null, AUTHORID varchar(50) not null, CREATIONDATE varchar(25) null, LASTMODIFIEDDATE varchar(25) null, UPDATENUMBER int null, PREVREVISIONNUM int null, LASTCMD int null, LASTCMDACLVERSION int null, USERDEFINEDFIELD varchar(300) null, LASTMODIFIEDBYID varchar(50) null, PARTICIPANTSTATE int not null, PARTICIPANTROLE int not null, PARTICIPANTTEAM int not null, ISREQUIREDMEMBER varchar(1) null, USERID varchar(50) null, ISAGENT varchar(1) null, NAME varchar(150) not null, EMAILADDRESS varchar(200) not null, ISEMAILONLY varchar(1) not null, INVITATION text null, ACCEPTRESENDCOUNT int null, ACCEPTRESENDTIMEOUT varchar(25) null, ACCEPTLASTSENTTONODEID varchar(50) null, constraint PK_PARTICIPANTS primary key (ISSUEID, OBJECTID));
        CREATE TABLE PARTICIPANTSETTINGS(CLASSID int null, SEQNO int not null, LASTMODONNODEID varchar(50) not null, PREVMODONNODEID varchar(50) null, ISSUEID varchar(50) not null, OBJECTID varchar(50) not null, REVISIONNUM int not null, CONTAINERID varchar(50) not null, AUTHORID varchar(50) not null, CREATIONDATE varchar(25) null, LASTMODIFIEDDATE varchar(25) null, UPDATENUMBER int null, PREVREVISIONNUM int null, LASTCMD int null, LASTCMDACLVERSION int null, USERDEFINEDFIELD varchar(300) null, LASTMODIFIEDBYID varchar(50) null, PARTICIPANTID varchar(50) not null, TASKPIMSYNC varchar(1) null, MOBILESUPPORT varchar(1) null, NOTIFYBYEMAIL varchar(1) null, MARKEDCRITICAL varchar(1) null, constraint PK_PARTICIPANTSETTINGS primary key (ISSUEID, OBJECTID));
        CREATE TABLE PARTITIONS(id INT primary key, PARTITIONID varchar(50) not null, NAME varchar(100) not null, LDAPDN varchar(300) not null, SERVERNODEID varchar(50) not null, TQUNID varchar(36) not null);
        CREATE TABLE PROJECTS(CLASSID int null, SEQNO int not null, LASTMODONNODEID varchar(50) not null, PREVMODONNODEID varchar(50) null, ISSUEID varchar(50) not null, OBJECTID varchar(50) not null, REVISIONNUM int not null, CONTAINERID varchar(50) not null, AUTHORID varchar(50) not null, CREATIONDATE varchar(25) null, LASTMODIFIEDDATE varchar(25) null, UPDATENUMBER int null, PREVREVISIONNUM int null, LASTCMD int null, LASTCMDACLVERSION int null, USERDEFINEDFIELD varchar(300) null, LASTMODIFIEDBYID varchar(50) null, NAME varchar(100) not null, ID varchar(100) null, constraint PK_PROJECTS primary key (ISSUEID, OBJECTID));
        CREATE TABLE TASKCOMPLETIONS(CLASSID int null, SEQNO int not null, LASTMODONNODEID varchar(50) not null, PREVMODONNODEID varchar(50) null, ISSUEID varchar(50) not null, OBJECTID varchar(50) not null, REVISIONNUM int not null, CONTAINERID varchar(50) not null, AUTHORID varchar(50) not null, CREATIONDATE varchar(25) null, LASTMODIFIEDDATE varchar(25) null, UPDATENUMBER int null, PREVREVISIONNUM int null, LASTCMD int null, LASTCMDACLVERSION int null, USERDEFINEDFIELD varchar(300) null, LASTMODIFIEDBYID varchar(50) null, PARENTENTITYID varchar(50) null, BODY text null, BODYCONTENTTYPE varchar(100) null, ISOBSOLETE varchar(1) null, TASKID varchar(50) not null, DISPOSITION int not null, STATUSID varchar(50) not null, SHORTNAME varchar(30) not null, LONGNAME varchar(200) not null, constraint PK_TASKCOMPLETIONS primary key (ISSUEID, OBJECTID));
        CREATE TABLE TASKS(CLASSID int null, SEQNO int not null, LASTMODONNODEID varchar(50) not null, PREVMODONNODEID varchar(50) null, ISSUEID varchar(50) not null, OBJECTID varchar(50) not null, REVISIONNUM int not null, CONTAINERID varchar(50) not null, AUTHORID varchar(50) not null, CREATIONDATE varchar(25) null, LASTMODIFIEDDATE varchar(25) null, UPDATENUMBER int null, PREVREVISIONNUM int null, LASTCMD int null, LASTCMDACLVERSION int null, USERDEFINEDFIELD varchar(300) null, LASTMODIFIEDBYID varchar(50) null, PARENTENTITYID varchar(50) null, BODY text null, BODYCONTENTTYPE varchar(100) null, ISOBSOLETE varchar(1) null, DUETIME varchar(25) null, ASSIGNEDTO varchar(50) not null, TARGETOBJECTIDS text null, RESPONSEID varchar(50) not null, TYPEID varchar(50) not null, LABEL varchar(200) not null, INSTRUCTIONS text not null, ALLOWEDSTATUSES text not null, ISSERIALREVIEW varchar(1) null, DAYSTOREVIEW int null, REVIEWERIDS varchar(500) null, REVIEWTYPE int null, REVIEWGROUP varchar(300) null, constraint PK_TASKS primary key (ISSUEID, OBJECTID));
        CREATE TABLE USERS (id INT primary key, USERID varchar(50) not null, USERSID varchar(100) not null, ENTERPRISEUSER varchar(1) not null, USEREMAILADDRESS varchar(200) null, EMAILVALIDATED varchar(1) null, VALIDATIONCOOKIE varchar(50) null, CREATETIME varchar(25) not null, TQUNID varchar(36) not null, PARTITIONID varchar(50) null);
        CREATE VIEW CRITICALISSUES as


            select
                    USERID, ISSUEID, ISSUENAME, min(DATE1) DATE1
                    from (
                    select p.USERID USERID, p.ISSUEID ISSUEID, iset.ISSUENAME ISSUENAME, t.DUETIME DATE1
                        from PARTICIPANTS p
                        join TASKS t on t.ASSIGNEDTO = p.OBJECTID
                        join TASKCOMPLETIONS tc on tc.TASKID = t.OBJECTID
                        join ISSUESETTINGS iset on iset.ISSUEID = p.ISSUEID
                        where (t.ISOBSOLETE = 'n' or t.ISOBSOLETE is null)
                        and tc.DISPOSITION = 1
                        and iset.ISSUESTATUS = 1
                    union
                    select p.USERID USERID, p.ISSUEID ISSUEID, iset.ISSUENAME ISSUENAME, iset.ISSUEDUEDATE DATE1
                        from PARTICIPANTS p
                        join PARTICIPANTSETTINGS ps on ps.PARTICIPANTID = p.OBJECTID
                        join ISSUESETTINGS iset on iset.ISSUEID = p.ISSUEID
                        where ps.MARKEDCRITICAL = 'y'
                        and iset.ISSUESTATUS = 1
                    ) as CRITICALDATA
                    group by USERID, ISSUEID, ISSUENAME;
        CREATE VIEW CURRENTFILES as


            select
                    d.ISSUEID as ISSUEID,
                    d.REFERENCEDOCUMENTID as OBJECTID,
                    f.VISIBLENAME as VISIBLENAME
                    from
                        DOCREFERENCES d
                        join FILES f on f.OBJECTID = d.REFERENCEDOCUMENTID;
        CREATE VIEW ISSUEDATA as


            select
                    ISSUES.OBJECTID as ISSUEID,
                    ISSUES.CREATIONDATE as CREATIONDATE,
                    ISSUES.AUTHORID as AUTHORID,
                    ISSUES.LASTMODIFIEDDATE as LASTMODIFIEDDATE,
                    ISSUES.LASTMODIFIEDBYID as LASTMODIFIEDBYID,
                    ISSUESETTINGS.ISSUENAME as ISSUENAME,
                    ISSUES.ISINITIALIZED as ISINITIALIZED,
                    ISSUES.ISSYSTEMISSUE as ISSYSTEMISSUE,
                    ISSUES.ISSUETYPE as ISSUETYPE,
                    ISSUES.ISINCOMPLETE as ISINCOMPLETE,
                    ISSUESETTINGS.REVISIONNUM as ISSUESETTINGS_REVISIONNUM,
                    ISSUESETTINGS.LASTMODIFIEDDATE as ISSUESETTINGS_LASTMODIFIEDDATE,
                    ISSUESETTINGS.LASTMODIFIEDBYID as ISSUESETTINGS_LASTMODIFIEDBYID,
                    ISSUESETTINGS.ISSUEDUEDATE as ISSUEDUEDATE,
                    ISSUESETTINGS.ISSUEPRIORITY as ISSUEPRIORITY,
                    ISSUESETTINGS.ISSUESTATUS as ISSUESTATUS,
                    ISSUESETTINGS.DESCRIPTION as DESCRIPTION,
                    ISSUESETTINGS.PROJECTID as PROJECTID,
                    ISSUESETTINGS.PROJECTNAME as PROJECTNAME,
                    ISSUESETTINGS.PROJECTNAMEISCUSTOM as PROJECTNAMEISCUSTOM,
                    ENTERPRISEDATA.REVISIONNUM as ENTERPRISEDATA_REVISIONNUM,
                    ENTERPRISEDATA.CREATIONDATE as ENTERPRISEDATA_CREATIONDATE,
                    ENTERPRISEDATA.AUTHORID as ENTERPRISEDATA_AUTHORID,
                    ENTERPRISEDATA.LASTMODIFIEDDATE as ENTERPRISEDATA_LASTMODIFIEDDATE,
                    ENTERPRISEDATA.LASTMODIFIEDBYID as ENTERPRISEDATA_LASTMODIFIEDBYID,
                    ENTERPRISEDATA.DATE1 as DATE1,
                    ENTERPRISEDATA.DATE2 as DATE2,
                    ENTERPRISEDATA.DATE3 as DATE3,
                    ENTERPRISEDATA.DATE4 as DATE4,
                    ENTERPRISEDATA.DATE5 as DATE5,
                    ENTERPRISEDATA.DATE6 as DATE6,
                    ENTERPRISEDATA.DATE7 as DATE7,
                    ENTERPRISEDATA.DATE8 as DATE8,
                    ENTERPRISEDATA.DATE9 as DATE9,
                    ENTERPRISEDATA.DATE10 as DATE10,
                    ENTERPRISEDATA.VALUE1 as VALUE1,
                    ENTERPRISEDATA.VALUE2 as VALUE2,
                    ENTERPRISEDATA.VALUE3 as VALUE3,
                    ENTERPRISEDATA.VALUE4 as VALUE4,
                    ENTERPRISEDATA.VALUE5 as VALUE5,
                    ENTERPRISEDATA.VALUE6 as VALUE6,
                    ENTERPRISEDATA.VALUE7 as VALUE7,
                    ENTERPRISEDATA.VALUE8 as VALUE8,
                    ENTERPRISEDATA.VALUE9 as VALUE9,
                    ENTERPRISEDATA.VALUE10 as VALUE10,
                    ENTERPRISEDATA.VALUE11 as VALUE11,
                    ENTERPRISEDATA.VALUE12 as VALUE12,
                    ENTERPRISEDATA.VALUE13 as VALUE13,
                    ENTERPRISEDATA.VALUE14 as VALUE14,
                    ENTERPRISEDATA.VALUE15 as VALUE15,
                    ENTERPRISEDATA.VALUE16 as VALUE16,
                    ENTERPRISEDATA.VALUE17 as VALUE17,
                    ENTERPRISEDATA.VALUE18 as VALUE18,
                    ENTERPRISEDATA.VALUE19 as VALUE19,
                    ENTERPRISEDATA.VALUE20 as VALUE20,
                    ENTERPRISEDATA.STRING1 as STRING1,
                    ENTERPRISEDATA.STRING2 as STRING2,
                    ENTERPRISEDATA.STRING3 as STRING3,
                    ENTERPRISEDATA.STRING4 as STRING4,
                    ENTERPRISEDATA.STRING5 as STRING5,
                    ENTERPRISEDATA.STRING6 as STRING6,
                    ENTERPRISEDATA.STRING7 as STRING7,
                    ENTERPRISEDATA.STRING8 as STRING8,
                    ENTERPRISEDATA.STRING9 as STRING9,
                    ENTERPRISEDATA.STRING10 as STRING10,
                    ENTERPRISEDATA.LONGSTRING1 as LONGSTRING1,
                    ENTERPRISEDATA.LONGSTRING2 as LONGSTRING2,
                    ENTERPRISEDATA.LONGSTRING3 as LONGSTRING3,
                    ENTERPRISEDATA.LONGSTRING4 as LONGSTRING4,
                    ENTERPRISEDATA.LONGSTRING5 as LONGSTRING5,
                    ENTERPRISEDATA.LONGSTRING6 as LONGSTRING6,
                    ENTERPRISEDATA.LONGSTRING7 as LONGSTRING7,
                    ENTERPRISEDATA.LONGSTRING8 as LONGSTRING8,
                    ENTERPRISEDATA.LONGSTRING9 as LONGSTRING9,
                    ENTERPRISEDATA.LONGSTRING10 as LONGSTRING10
                from
                    ISSUES
                    join ISSUESETTINGS on ISSUES.OBJECTID = ISSUESETTINGS.ISSUEID
                    left outer join ENTERPRISEDATA on ISSUES.OBJECTID = ENTERPRISEDATA.ISSUEID;
        CREATE VIEW ITEMS as

        select 'FILES' as TABLENAME, CLASSID, SEQNO, LASTMODONNODEID, PREVMODONNODEID, ISSUEID, OBJECTID, REVISIONNUM, CONTAINERID, AUTHORID, CREATIONDATE, LASTMODIFIEDDATE, UPDATENUMBER, PREVREVISIONNUM, LASTCMD, LASTCMDACLVERSION, USERDEFINEDFIELD, LASTMODIFIEDBYID, PARENTENTITYID, BODY, BODYCONTENTTYPE, ISOBSOLETE, FILENAME, VISIBLENAME, VERSIONSTRING, DOCUMENTHASH, ISFINAL, DOCREFERENCEID, NULL as ACTIONTYPE, NULL as ASSOCIATEDOBJECTIDS, NULL as OLDENTITIES, NULL as NEWENTITIES, NULL as OTHERENTITIES, NULL as TQUNID, NULL as TABLEITEMID, NULL as TABLENODEID, NULL as TABLECMD, NULL as TABLECONTAINERID, NULL as TABLESEQNO, NULL as DIRTYCONTENT, NULL as STUBBED, NULL as ENTITYSTUBDATA, NULL as PARTICIPANTSTATE, NULL as PARTICIPANTROLE, NULL as PARTICIPANTTEAM, NULL as ISREQUIREDMEMBER, NULL as USERID, NULL as ISAGENT, NULL as NAME, NULL as EMAILADDRESS, NULL as ISEMAILONLY, NULL as INVITATION, NULL as ACCEPTRESENDCOUNT, NULL as ACCEPTRESENDTIMEOUT, NULL as ACCEPTLASTSENTTONODEID, NULL as TASKID, NULL as DISPOSITION, NULL as STATUSID, NULL as SHORTNAME, NULL as LONGNAME, NULL as DUETIME, NULL as ASSIGNEDTO, NULL as TARGETOBJECTIDS, NULL as RESPONSEID, NULL as TYPEID, NULL as LABEL, NULL as INSTRUCTIONS, NULL as ALLOWEDSTATUSES, NULL as ISSERIALREVIEW, NULL as DAYSTOREVIEW, NULL as REVIEWERIDS, NULL as REVIEWTYPE, NULL as REVIEWGROUP from FILES
        union all
        select 'LOGENTRIES' as TABLENAME, CLASSID, SEQNO, LASTMODONNODEID, PREVMODONNODEID, ISSUEID, OBJECTID, REVISIONNUM, CONTAINERID, AUTHORID, CREATIONDATE, LASTMODIFIEDDATE, UPDATENUMBER, PREVREVISIONNUM, LASTCMD, LASTCMDACLVERSION, USERDEFINEDFIELD, LASTMODIFIEDBYID, PARENTENTITYID, BODY, BODYCONTENTTYPE, ISOBSOLETE, NULL as FILENAME, NULL as VISIBLENAME, NULL as VERSIONSTRING, NULL as DOCUMENTHASH, NULL as ISFINAL, NULL as DOCREFERENCEID, ACTIONTYPE, ASSOCIATEDOBJECTIDS, OLDENTITIES, NEWENTITIES, OTHERENTITIES, NULL as TQUNID, NULL as TABLEITEMID, NULL as TABLENODEID, NULL as TABLECMD, NULL as TABLECONTAINERID, NULL as TABLESEQNO, NULL as DIRTYCONTENT, NULL as STUBBED, NULL as ENTITYSTUBDATA, NULL as PARTICIPANTSTATE, NULL as PARTICIPANTROLE, NULL as PARTICIPANTTEAM, NULL as ISREQUIREDMEMBER, NULL as USERID, NULL as ISAGENT, NULL as NAME, NULL as EMAILADDRESS, NULL as ISEMAILONLY, NULL as INVITATION, NULL as ACCEPTRESENDCOUNT, NULL as ACCEPTRESENDTIMEOUT, NULL as ACCEPTLASTSENTTONODEID, NULL as TASKID, NULL as DISPOSITION, NULL as STATUSID, NULL as SHORTNAME, NULL as LONGNAME, NULL as DUETIME, NULL as ASSIGNEDTO, NULL as TARGETOBJECTIDS, NULL as RESPONSEID, NULL as TYPEID, NULL as LABEL, NULL as INSTRUCTIONS, NULL as ALLOWEDSTATUSES, NULL as ISSERIALREVIEW, NULL as DAYSTOREVIEW, NULL as REVIEWERIDS, NULL as REVIEWTYPE, NULL as REVIEWGROUP from LOGENTRIES
        union all
        select 'LSBI' as TABLENAME, NULL as CLASSID, NULL as SEQNO, NULL as LASTMODONNODEID, NULL as PREVMODONNODEID, ISSUEID, NULL as OBJECTID, NULL as REVISIONNUM, NULL as CONTAINERID, NULL as AUTHORID, NULL as CREATIONDATE, NULL as LASTMODIFIEDDATE, UPDATENUMBER, NULL as PREVREVISIONNUM, NULL as LASTCMD, NULL as LASTCMDACLVERSION, NULL as USERDEFINEDFIELD, NULL as LASTMODIFIEDBYID, NULL as PARENTENTITYID, NULL as BODY, NULL as BODYCONTENTTYPE, NULL as ISOBSOLETE, NULL as FILENAME, NULL as VISIBLENAME, NULL as VERSIONSTRING, NULL as DOCUMENTHASH, NULL as ISFINAL, NULL as DOCREFERENCEID, NULL as ACTIONTYPE, NULL as ASSOCIATEDOBJECTIDS, NULL as OLDENTITIES, NULL as NEWENTITIES, NULL as OTHERENTITIES, TQUNID, TABLEITEMID, TABLENODEID, TABLECMD, TABLECONTAINERID, TABLESEQNO, DIRTYCONTENT, STUBBED, ENTITYSTUBDATA, NULL as PARTICIPANTSTATE, NULL as PARTICIPANTROLE, NULL as PARTICIPANTTEAM, NULL as ISREQUIREDMEMBER, NULL as USERID, NULL as ISAGENT, NULL as NAME, NULL as EMAILADDRESS, NULL as ISEMAILONLY, NULL as INVITATION, NULL as ACCEPTRESENDCOUNT, NULL as ACCEPTRESENDTIMEOUT, NULL as ACCEPTLASTSENTTONODEID, NULL as TASKID, NULL as DISPOSITION, NULL as STATUSID, NULL as SHORTNAME, NULL as LONGNAME, NULL as DUETIME, NULL as ASSIGNEDTO, NULL as TARGETOBJECTIDS, NULL as RESPONSEID, NULL as TYPEID, NULL as LABEL, NULL as INSTRUCTIONS, NULL as ALLOWEDSTATUSES, NULL as ISSERIALREVIEW, NULL as DAYSTOREVIEW, NULL as REVIEWERIDS, NULL as REVIEWTYPE, NULL as REVIEWGROUP from LSBI where TABLECMD=3
        union all
        select 'PARTICIPANTS' as TABLENAME, CLASSID, SEQNO, LASTMODONNODEID, PREVMODONNODEID, ISSUEID, OBJECTID, REVISIONNUM, CONTAINERID, AUTHORID, CREATIONDATE, LASTMODIFIEDDATE, UPDATENUMBER, PREVREVISIONNUM, LASTCMD, LASTCMDACLVERSION, USERDEFINEDFIELD, LASTMODIFIEDBYID, NULL as PARENTENTITYID, NULL as BODY, NULL as BODYCONTENTTYPE, NULL as ISOBSOLETE, NULL as FILENAME, NULL as VISIBLENAME, NULL as VERSIONSTRING, NULL as DOCUMENTHASH, NULL as ISFINAL, NULL as DOCREFERENCEID, NULL as ACTIONTYPE, NULL as ASSOCIATEDOBJECTIDS, NULL as OLDENTITIES, NULL as NEWENTITIES, NULL as OTHERENTITIES, NULL as TQUNID, NULL as TABLEITEMID, NULL as TABLENODEID, NULL as TABLECMD, NULL as TABLECONTAINERID, NULL as TABLESEQNO, NULL as DIRTYCONTENT, NULL as STUBBED, NULL as ENTITYSTUBDATA, PARTICIPANTSTATE, PARTICIPANTROLE, PARTICIPANTTEAM, ISREQUIREDMEMBER, USERID, ISAGENT, NAME, EMAILADDRESS, ISEMAILONLY, INVITATION, ACCEPTRESENDCOUNT, ACCEPTRESENDTIMEOUT, ACCEPTLASTSENTTONODEID, NULL as TASKID, NULL as DISPOSITION, NULL as STATUSID, NULL as SHORTNAME, NULL as LONGNAME, NULL as DUETIME, NULL as ASSIGNEDTO, NULL as TARGETOBJECTIDS, NULL as RESPONSEID, NULL as TYPEID, NULL as LABEL, NULL as INSTRUCTIONS, NULL as ALLOWEDSTATUSES, NULL as ISSERIALREVIEW, NULL as DAYSTOREVIEW, NULL as REVIEWERIDS, NULL as REVIEWTYPE, NULL as REVIEWGROUP from PARTICIPANTS
        union all
        select 'TASKCOMPLETIONS' as TABLENAME, CLASSID, SEQNO, LASTMODONNODEID, PREVMODONNODEID, ISSUEID, OBJECTID, REVISIONNUM, CONTAINERID, AUTHORID, CREATIONDATE, LASTMODIFIEDDATE, UPDATENUMBER, PREVREVISIONNUM, LASTCMD, LASTCMDACLVERSION, USERDEFINEDFIELD, LASTMODIFIEDBYID, PARENTENTITYID, BODY, BODYCONTENTTYPE, ISOBSOLETE, NULL as FILENAME, NULL as VISIBLENAME, NULL as VERSIONSTRING, NULL as DOCUMENTHASH, NULL as ISFINAL, NULL as DOCREFERENCEID, NULL as ACTIONTYPE, NULL as ASSOCIATEDOBJECTIDS, NULL as OLDENTITIES, NULL as NEWENTITIES, NULL as OTHERENTITIES, NULL as TQUNID, NULL as TABLEITEMID, NULL as TABLENODEID, NULL as TABLECMD, NULL as TABLECONTAINERID, NULL as TABLESEQNO, NULL as DIRTYCONTENT, NULL as STUBBED, NULL as ENTITYSTUBDATA, NULL as PARTICIPANTSTATE, NULL as PARTICIPANTROLE, NULL as PARTICIPANTTEAM, NULL as ISREQUIREDMEMBER, NULL as USERID, NULL as ISAGENT, NULL as NAME, NULL as EMAILADDRESS, NULL as ISEMAILONLY, NULL as INVITATION, NULL as ACCEPTRESENDCOUNT, NULL as ACCEPTRESENDTIMEOUT, NULL as ACCEPTLASTSENTTONODEID, TASKID, DISPOSITION, STATUSID, SHORTNAME, LONGNAME, NULL as DUETIME, NULL as ASSIGNEDTO, NULL as TARGETOBJECTIDS, NULL as RESPONSEID, NULL as TYPEID, NULL as LABEL, NULL as INSTRUCTIONS, NULL as ALLOWEDSTATUSES, NULL as ISSERIALREVIEW, NULL as DAYSTOREVIEW, NULL as REVIEWERIDS, NULL as REVIEWTYPE, NULL as REVIEWGROUP from TASKCOMPLETIONS
        union all
        select 'TASKS' as TABLENAME, CLASSID, SEQNO, LASTMODONNODEID, PREVMODONNODEID, ISSUEID, OBJECTID, REVISIONNUM, CONTAINERID, AUTHORID, CREATIONDATE, LASTMODIFIEDDATE, UPDATENUMBER, PREVREVISIONNUM, LASTCMD, LASTCMDACLVERSION, USERDEFINEDFIELD, LASTMODIFIEDBYID, PARENTENTITYID, BODY, BODYCONTENTTYPE, ISOBSOLETE, NULL as FILENAME, NULL as VISIBLENAME, NULL as VERSIONSTRING, NULL as DOCUMENTHASH, NULL as ISFINAL, NULL as DOCREFERENCEID, NULL as ACTIONTYPE, NULL as ASSOCIATEDOBJECTIDS, NULL as OLDENTITIES, NULL as NEWENTITIES, NULL as OTHERENTITIES, NULL as TQUNID, NULL as TABLEITEMID, NULL as TABLENODEID, NULL as TABLECMD, NULL as TABLECONTAINERID, NULL as TABLESEQNO, NULL as DIRTYCONTENT, NULL as STUBBED, NULL as ENTITYSTUBDATA, NULL as PARTICIPANTSTATE, NULL as PARTICIPANTROLE, NULL as PARTICIPANTTEAM, NULL as ISREQUIREDMEMBER, NULL as USERID, NULL as ISAGENT, NULL as NAME, NULL as EMAILADDRESS, NULL as ISEMAILONLY, NULL as INVITATION, NULL as ACCEPTRESENDCOUNT, NULL as ACCEPTRESENDTIMEOUT, NULL as ACCEPTLASTSENTTONODEID, NULL as TASKID, NULL as DISPOSITION, NULL as STATUSID, NULL as SHORTNAME, NULL as LONGNAME, DUETIME, ASSIGNEDTO, TARGETOBJECTIDS, RESPONSEID, TYPEID, LABEL, INSTRUCTIONS, ALLOWEDSTATUSES, ISSERIALREVIEW, DAYSTOREVIEW, REVIEWERIDS, REVIEWTYPE, REVIEWGROUP from TASKS;
        CREATE VIEW TASKINFO as


            select
                    t.ISSUEID as ISSUEID,
                    t.OBJECTID as OBJECTID,
                    t.ASSIGNEDTO as ASSIGNEDTO,
                    t.TARGETOBJECTIDS as TARGETOBJECTIDS,
                    t.DUETIME as DUETIME,
                    t.ISOBSOLETE as ISOBSOLETE,
                    tc.DISPOSITION as DISPOSITION
                    from
                        TASKS t
                        join TASKCOMPLETIONS tc on tc.TASKID = t.OBJECTID;
        CREATE INDEX DQ_ISSUEID_DEPENDSID on DQ (ISSUEID, DEPENDSID);
        CREATE INDEX EMAILQ_TIMEQUEUED on EMAILQ (TIMEQUEUED);
        CREATE INDEX FOLDERS_CONTAINERID_ISSUEID on FOLDERS (CONTAINERID, ISSUEID);
        CREATE INDEX IMQ_DATETIMEQUEUED on IMQ (DATETIMEQUEUED);
        CREATE INDEX INVITATIONS_RECIPIENTUSERID_INVITATIONID on INVITATIONS (RECIPIENTUSERID, INVITATIONID);
        CREATE INDEX INVITATIONS_TQUNID on INVITATIONS (TQUNID);
        CREATE INDEX ISSUESETTINGS_CONTAINERID on ISSUESETTINGS (CONTAINERID);
        CREATE INDEX KMTPMSG_RECEIVEDDATE on KMTPMSG (RECEIVEDDATE desc);
        CREATE INDEX KMTPNODEQ_MSGID on KMTPNODEQ (MSGID);
        CREATE INDEX KMTPNODEQ_NODEID_MSGID on KMTPNODEQ (NODEID, MSGID);
        CREATE INDEX KMTPNODEQ_RECEIVEDDATE on KMTPNODEQ (RECEIVEDDATE desc);
        CREATE INDEX LSBI_ISSUEID_TABLEITEMID on LSBI (ISSUEID, TABLEITEMID);
        CREATE INDEX LSBN_ISSUEID_NODEID on LSBN (ISSUEID, NODEID);
        CREATE INDEX MMQ_ISSUEID_MMQENTRYINDEX on MMQ (ISSUEID, MMQENTRYINDEX);
        CREATE INDEX NODEREG_NODEID_USERID on NODEREG (NODEID, USERID);
        CREATE INDEX NODEREG_TQUNID on NODEREG (TQUNID);
        CREATE INDEX NODEREG_USERID_NODEID on NODEREG (USERID, NODEID);
        CREATE INDEX NODES_NODEID on NODES (NODEID);
        CREATE INDEX NODES_TQUNID on NODES (TQUNID);
        CREATE INDEX PARTICIPANTNODES_ISSUEID_OBJECTID_NODEID on PARTICIPANTNODES (ISSUEID, OBJECTID, NODEID);
        CREATE INDEX PARTICIPANTNODES_TQUNID on PARTICIPANTNODES (TQUNID);
        CREATE INDEX PARTICIPANTSETTINGS_PARTICIPANTID on PARTICIPANTSETTINGS (PARTICIPANTID);
        CREATE INDEX PARTITIONS_LDAPDN on PARTITIONS (LDAPDN);
        CREATE INDEX PARTITIONS_PARTITIONID_SERVERNODEID on PARTITIONS (PARTITIONID, SERVERNODEID);
        CREATE INDEX PARTITIONS_SERVERNODEID_PARTITIONID on PARTITIONS (SERVERNODEID, PARTITIONID);
        CREATE INDEX PARTITIONS_TQUNID on PARTITIONS (TQUNID);
        CREATE INDEX TASKCOMPLETIONS_TASKID on TASKCOMPLETIONS (TASKID);
        CREATE INDEX TASKS_ASSIGNEDTO on TASKS (ASSIGNEDTO);
        CREATE INDEX USERS_PARTITIONID_USERID on USERS (PARTITIONID, USERID);
        CREATE INDEX USERS_TQUNID on USERS (TQUNID);
        CREATE INDEX USERS_USERID_PARTITIONID on USERS (USERID, PARTITIONID);
        CREATE INDEX USERS_USERSID_USERID on USERS (USERSID, USERID);
        -- COMMIT;
    ]], {
        -- <tkt1449-1.1>

        -- </tkt1449-1.1>
    })

-- Given the schema above, the following query was cause an assertion fault
-- do to an uninitialized field in a Select structure.
--
test:do_execsql_test(
    "tkt1449-1.2",
    [[
        select NEWENTITIES from ITEMS where ((ISSUEID = 'x') and (OBJECTID = 'y'))
    ]], {
        -- <tkt1449-1.2>

        -- </tkt1449-1.2>
    })

test:do_execsql_test(
    "tkt1449-1.3",
    [[
        SELECT * FROM CRITICALISSUES;
    ]], {
        -- <tkt1449-1.3>

        -- </tkt1449-1.3>
    })

test:finish_test()

