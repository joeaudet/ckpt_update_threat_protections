#!/bin/bash

# get CP environment
. /etc/profile.d/CP.sh

# check if script is running with root privileges
if [ ${EUID} -ne 0 ];then
  echo "Please run as admin";
  exit 1
fi

#Define misc variables
THREAT_PROFILE="";  # Name of the threat profile you want to update
DOMAIN="";          # If not an MDS server leave blank, script will check before execution
API_USERNAME="";    # API username to login to the Mgmt server with
API_PASSWORD="";    # API user password - can be replaced with a shell variable to not store the password in the script

# Login to system, store session info for later use sid.txt file
# Not using the -R option due to implicit publish on end of every command, performance would suffer
# Process differently for an SMS versus an MDS server
if [ -z ${MDSVERUTIL+x} ]
then
    #If not an MDS server
    mgmt_cli login user "$API_USERNAME" password "$API_PASSWORD" --format json > sid.txt
else
    #If an MDS login to the defined domain
    mgmt_cli login user "$API_USERNAME" password "$API_PASSWORD" domain "$DOMAIN" --format json > sid.txt
fi

# Declare an array for iteration
# Check Point API calls use either the UUID or threat protection name to access the object and make changes to it
declare -a arr=(
"Adobe ColdFusion Directory Traversal (APSB10-18)"
"Adobe Flash Media Server Resource Exhaustion Denial of Service (APSB09-18)"
"Adobe Flash Player ActionScript 2 Record Out Of Boundary (APSB11-21)"
"Adobe Flash Player ActionScript 3 Movie Canvas Memory Corruption (APSB11-21)"
"Adobe Flash Player ActionScript 3 RegExp Memory Corruption (APSB11-21)"
"Adobe Flash Player External MP4 Buffer Overflow (APSB11-21)"
"Adobe Flash Player Integer Overflow Remote Code Execution (APSB16-01: CVE-2015-8651)"
"Adobe Flash Player Remote Code Execution (APSA16-01: CVE-2016-1019)"
"Adobe PageMaker Key Strings Stack Buffer Overflow"
"Adobe Reader Malformed Entries Memory Corruption (APSB12-16)"
"Adobe Reader WKT String Buffer Overflow (APSB12-16)"
"Adobe RoboHelp Server Arbitrary File Upload and Execute"
"AlienVault OSSIM av-centerd SOAP Requests Multiple Command Execution - ver 2"
"Apache Roller OGNL Injection Remote Code Execution"
"Apache Struts Debugging Interceptor Remote Code Execution"
"Apache Struts URL and Anchor tag includeParams OGNL Command Execution"
"Apache Struts Wildcard Matching OGNL Code Execution - High Confidence"
"Apache Struts2 Content-Type Remote Code Execution"
"Apache Struts2 ParametersInterceptor Remote Command Execution"
"Apple CUPS cupsd Privilege Escalation"
"ASUSWRT LAN Backdoor Remote Command Execution"
"Avaya IP Office CCR ImageUpload.ashx Unrestricted File Upload"
"BIND 9 DNS Server Dynamic Update Denial of Service - High Confidence"
"Bugzilla Privilege Escalation - Email Validation Bypass"
"CA Total Defense Suite UNCWS getDBConfigSettings Credential Information Disclosure"
"CA Total Defense Suite UNCWS Multiple Report Stored Procedure SQL Injections"
"China Chopper Web Shell Remote Code Execution"
"Cisco Network Registrar Default Credentials Authentication Bypass"
"Cisco NX-OS Interface Commands Privilege Escalation"
"Cisco Prime LAN Management Solution Remote Command Execution"
"Cisco Security Agent Management Center Code Execution"
"Domain Name Fake SSL Certificate"
"DotNetNuke Administration Authentication Bypass"
"Exim MTA BDAT Denial Of Service (CVE-2017-16944)"
"Foxit Reader PDF Arbitrary File Write Remote Code Execution (CVE-2017-10952)"
"Foxit Reader PDF Command Injection Remote Code Execution (CVE-2017-10951)"
"GNU Bash Remote Code Execution"
"Havij Automated SQL Injection tool"
"HP Database Archiving Software GIOP Opcode 0x0E Buffer Overflow"
"HP Database Archiving Software GIOP Parsing Buffer Overflow"
"HP Diagnostics magentservice.exe Stack Buffer Overflow"
"HP iNode Management Center iNodeMngChecker.exe Stack Buffer Overflow"
"HP Intelligent Management Center dbman Buffer Overflow"
"HP Intelligent Management Center iNodeMngChecker.exe Buffer Overflow"
"HP Intelligent Management Center tftpserver.exe Remote Code Execution"
"HP Intelligent Management Center uam.exe Stack Buffer Overflow"
"HP LeftHand Virtual SAN Appliance hydra Diag Processing Buffer Overflow"
"HP LeftHand Virtual SAN Appliance Hydra Login Code Execution"
"HP LeftHand Virtual SAN Appliance hydra Ping Processing Buffer Overflow"
"HP LeftHand Virtual SAN Appliance hydra SNMP Processing Buffer Overflow"
"HP LoadRunner launcher.dll Stack Buffer Overflow"
"HP LoadRunner magentproc.exe Stack Buffer Overflow"
"HP LoadRunner XDR Data Handling Heap Buffer Overflow"
"HP Network Node Manager I ovopi.dll Buffer Overflow"
"HP Network Node Manager I ovopi.dll Command 685 Memory Corruption"
"HP OpenView Network Node Manager Denial of Service"
"HP OpenView Network Node Manager Multiple Buffer Overflows"
"HP OpenView Performance Insight Server Backdoor Account Code Execution"
"HP OpenView Storage Data Protector EXEC_CMD Buffer Overflow"
"HP OpenView Storage Stack Buffer Overflow"
"HP Operations Agent Opcode Stack Buffer Overflow"
"HP Operations Manager Server Unauthorized File Upload"
"HP Power Manager formExportDataLogs Directory Traversal"
"HP Service Virtualization AutoPass License Server Directory Traversal"
"Huawei HG532 Router Remote Code Execution"
"IBM Cognos tm1admsd.exe Buffer Overflow"
"IBM DB2 Database Server CONNECT Request Denial of Service"
"IBM DB2 Universal Database receiveDASMessage Buffer Overflow"
"IBM Domino LDAP Server ModifyRequest Stack Buffer Overflow"
"IBM Informix Dynamic Server librpc.dll Multiple Buffer Overflows"
"IBM Lotus Domino LDAP Heap Buffer Overflow"
"IBM Lotus Domino nrouter.exe iCalendar MAILTO Stack Buffer Overflow"
"IBM Tivoli Storage Manager Client CAD Service Buffer Overflow"
"IBM Tivoli Storage Manager FastBack Mount Opcode 0x09 Stack Buffer Overflow"
"IBM Tivoli Storage Manager FastBack Mount Service Code Execution"
"IBM Tivoli Storage Manager FastBack Mount Stack Buffer Overflow"
"IBM Tivoli Storage Manager FastBack Mount vault Stack Buffer Overflow"
"IBM WebSphere Application Server Commons-Collections Library Remote Code Execution"
"Illegal TCP Options"
"ImageMagick GIF Comment Processing Off-by-one Buffer Overflow"
"Intel AMT Framework Unauthorized Admin Entry (CVE-2017-5689)"
"Internet Explorer ActiveX Control hxvz.dll Memory Corruption (MS08-023)"
"Internet Explorer COM Object Instantiation Memory Corruption (MS07-016)"
"Internet Explorer tblinf32.dll ActiveX Object Code Execution (MS07-045)"
"Internet Explorer URL Cache Memory Corruption (MS08-073)"
"Internet Explorer VML Rect Fill Method Buffer Overflow (MS06-055)"
"iSCSI target Multiple Implementations iSNS Stack Buffer Overflow - High Confidence"
"JavaScript Malicious Obfuscation Techniques"
"Joomla com_fields Component SQL Injection"
"Joomla Content Editor Malicious User Agent Code Execution"
"Joomla LDAP Information Disclosure (CVE-2017-14596)"
"Joomla Object Injection Remote Command Execution"
"Joomla ofc_upload_image.php Unrestricted File Upload"
"Joomla Unauthorized File Upload Remote Code Execution"
"jQuery Suspicious URL Redirection"
"Lexmark MarkVision Enterprise GfdFileUploadServlet Directory Traversal"
"libpng png_inflate Buffer Overflow - High Confidence"
"Linux EternalRed Samba Remote Code Execution"
"Linux Kernel iscsi_add_notunderstood_response Heap Buffer Overflow - Improved Performance"
"Magento eCommerce Web Sites Remote File Inclusion"
"Magento eCommerce Web Sites SQL Injection"
"ManageEngine Multiple Products FileCollector doPost Directory Traversal"
"Microsoft .NET Framework Remote Code Execution (CVE-2017-8759)"
"Microsoft Data Access ADODB.Connection Object Memory Corruption (MS07-009)"
"Microsoft Data Access Components Overflow"
"Microsoft DirectAccess ICMP Denial of Service (MS13-064)"
"Microsoft Exchange Server EMSMDB32 Literal Processing (MS09-003)"
"Microsoft Graphics Component Information Disclosure (CVE-2017-0283)"
"Microsoft IIS 5.0 ISAPI Internet Printing Protocol Extension Buffer Overflow - ver 2"
"Microsoft IIS FTP Server Telnet IAC Buffer Overflow"
"Microsoft IIS idq.dll IDAIDQ ISAPI Overflow Buffer Overflow - Ver2"
"Microsoft IIS4 Exair Sample Site Denial Of Service"
"Microsoft Internet Explorer Jscript9 Memory Corruption (MS15-065: CVE-2015-2419)"
"Microsoft Internet Explorer SLayoutRun Use After Free (MS13-009) - High Confidence"
"Microsoft Malware Protection Engine Crafted PDF Code Execution (MS07-010)"
"Microsoft Malware Protection Engine VFS API Remote Code Execution (CVE-2017-8558)"
"Microsoft Media Services Stack-based Buffer Overflow (MS10-025)"
"Microsoft Office Files Containing Malicious Downloader"
"Microsoft Office Memory Corruption (MS15-033: CVE-2015-1641)"
"Microsoft Office MSODataSourceControl ActiveX Control Denial of Service"
"Microsoft Office Outlook mailto URI Handling Code Execution (MS08-015)"
"Microsoft Office RTF Stack Buffer Overflow (MS10-087)"
"Microsoft Remote Desktop Protocol Freed Memory Access (MS12-053)"
"Microsoft SMB COPY Command Pathname Overflow (MS10-012)"
"Microsoft SMB Crafted Write Request Remote Code Execution (MS11-020)"
"Microsoft SMB Response Parsing Memory Corruption (MS10-020) - High Confidence"
"Microsoft SQL 2000 Slammer Worm Denial of Service"
"Microsoft Telnet Client Information Disclosure (MS05-033)"
"Microsoft Visio Viewer ActiveX Control Remote Code Execution (MS09-055)"
"Microsoft Visual FoxPro ActiveX Control Buffer Overflow (MS08-010)"
"Microsoft Visual Studio WMI Object Code Execution (MS06-073)"
"Microsoft Windows CSRSS SrvDeviceEvent Code Execution (MS11-063)"
"Microsoft Windows DCOM RPC Interface Buffer Overflow (MS03-026)"
"Microsoft Windows EsteemAudit RDP Remote Code Execution"
"Microsoft Windows EternalBlue SMB Remote Code Execution"
"Microsoft Windows GDI EMF Image File Handling Stack Overflow (MS08-021)"
"Microsoft Windows GDI Metafile Image Handling Heap Overflow (MS08-021)"
"Microsoft Windows GDI+ VML Gradient Buffer Overflow (MS08-052)"
"Microsoft Windows HTML Help ActiveX Control Memory Corruption (MS07-008)"
"Microsoft Windows HTTP.sys Remote Code Execution (MS15-034: CVE-2015-1635)"
"Microsoft Windows Kerberos KDC Elevation of Privilege (MS14-068)"
"Microsoft Windows Live Mail ActiveX Remote Code Execution (MS09-055)"
"Microsoft Windows Malformed RTF Handling Code Execution (MS07-011)"
"Microsoft Windows Media Format ASF Parsing Buffer Overflow (MS06-078)"
"Microsoft Windows Message Queuing Service String Buffer Overflow (MS05-017)"
"Microsoft Windows OLE Automation Array Remote Code Execution (MS14-064)"
"Microsoft Windows RASMAN Service Memory Corruption (MS06-025)"
"Microsoft Windows Remote Desktop Protocol Code Execution (MS12-020)"
"Microsoft Windows Remote Desktop Protocol Code Execution (MS15-067: CVE-2015-2373)"
"Microsoft Windows SChannel Buffer Overflow (MS14-066)"
"Microsoft Windows Scripting Engines Script Encoding Code Execution (MS08-022)"
"Microsoft Windows Server Service RPC Request Buffer Overrun (MS06-040)"
"Microsoft Windows ShellExecute and IE7 URL Handling Code Execution (MS07-061)"
"Microsoft Windows SMB Client Repeated Negotiation Responses (MS10-006) - High Confidence"
"Microsoft Windows SMB mrxsmb.sys Remote Heap Overflow"
"Microsoft Windows SMB Negotiate Request Remote Code Execution"
"Microsoft Windows SMB Packet Buffer Overflow (MS05-027)"
"Microsoft Windows Workstation Service Buffer Overflow (MS06-070)"
"Microsoft WINS Buffer Allocation Integer Overflow (MS09-039)"
"Microsoft Word RTF Control Word Handling Integer Overflow (MS08-072)"
"Microsoft Word RTF Stylesheet Control Word Memory Corruption (MS08-072)"
"Moodle Remote Code Execution"
"Mozilla Firefox Browser Engine Memory Corruption"
"MSN Photo Upload Tool ActiveX Control Remote Code Execution (MS09-055)"
"Multiple Products Arbitrary File Location Upload"
"Multiple Products STARTTLS Plaintext Command Injection"
"Multiple Routers HNAP Insecure Implementation Privilege Escalation"
"Multiple Vendors OPIE Off-By-One Stack Buffer Overflow"
"Multiple Vendors Router TCP Backdoor Remote Code Execution"
"MySQL Into OutFile SQL Injection"
"Nagios statuswml.cgi Command Execution"
"Netflix Phishing Campaign Login and Billing Information"
"Nmap Scripting Engine Scanner Over HTTP Request"
"Novell File Reporter FSFUI File Upload"
"Novell ZENworks Asset Management Directory Traversal"
"Novell ZENworks Asset Management Web Console Information Disclosure"
"Novell ZENworks Configuration Management UploadServlet Directory Traversal"
"Nuclear Exploit Kit Landing Page"
"OpenSSL TLS DTLS Heartbeat Information Disclosure"
"OpenSSL TLS DTLS Overly-long Heartbeat Response Information Disclosure"
"Oracle 9i HTTP Server Globals.JSA Access Information Disclosure - Ver2"
"Oracle 9i HTTP Server soapConfig.xml Access Information Disclosure - Ver2"
"Oracle Application Server 10g emagent.exe Stack Buffer Overflow"
"Oracle Application Server 10g OPMN Service Format String"
"Oracle BEA WebLogic Server Apache Connector Buffer Overflow"
"Oracle Business Transaction Management Arbitrary File Creation"
"Oracle Business Transaction Management Arbitrary File Deletion"
"Oracle Database CTXSYS.DRVDISP.TABLEFUNC_ASOWN Buffer Overflow"
"Oracle Database DBMS TNS Listener Denial of Service"
"Oracle Database DBMS_JAVA.SET_OUTPUT_TO_JAVA Privilege Escalation"
"Oracle Database Server CREATE_TABLES SQL Injection"
"Oracle Database Server DBMS_AQELM Package Buffer Overflow"
"Oracle Database Server Insecure User Input Stack Buffer Overflow"
"Oracle Database Server Network Authentication AUTH_SESSKEY Buffer Overflow"
"Oracle Database Server REPCAT_RPC.VALIDATE_REMOTE_RC SQL Injection"
"Oracle Database Server Workspace Manager Multiple SQL Injection"
"Oracle Database Server XDB PITRIG TRUNCATE and DROP SQL Injection"
"Oracle Database Server XML Database Buffer Overflow"
"Oracle Database SYS.OLAPIMPL_T Package ODCITABLESTART Buffer Overflow"
"Oracle Endeca Server createDataStore Remote Command Execution"
"Oracle GoldenGate Veridata Server XML SOAP Request Buffer Overflow"
"Oracle Internet Directory Pre-Authentication LDAP Denial of Service"
"Oracle MySQL Server Geometry Query Integer Overflow - Improved Performance"
"Oracle Secure Backup Multiple Command Injections"
"Oracle Secure Backup NDMP CONNECT_CLIENT_AUTH Command Buffer Overflow"
"Oracle Warehouse Builder Stored Procedure SQL Injection"
"Oracle Warehouse Builder WB_OLAP_AW_REMOVE_SOLVE_ID SQL Injection"
"Oracle WebLogic Server Node Manager Command Execution"
"Oracle WebLogic WLS Security Component Remote Code Execution (CVE-2017-10271)"
"PHP PHP-Charts Remote Code Execution"
"PHP php_register_variable_ex Function Code Execution - High Confidence"
"PHP print Remote Shell Command Execution"
"PHP Web Shell Generic Backdoor"
"PHPMailer Mail From Remote Code Execution"
"PineApp Mail-SeCure livelog.html Command Injection"
"Plone and Zope cmd Parameter Remote Command Execution"
"Postfix SMTP Server SASL Authentication Memory Corruption"
"PowerPoint Malicious Hover Exploit"
"RIG Exploit Kit Landing Page"
"RIG Exploit Kit Website Redirection"
"Ruby on Rails JSON Processor YAML Deserialization Code Execution"
"Ruby on Rails XML Processor YAML Deserialization Code Execution"
"SQL Analysis Services Office Excel Add-in Remote Code Execution (MS09-055)"
"SQL Servers Blind SQL Injection"
"SQL Servers MSSQL Vendor-specific SQL Injection"
"SQL Servers MySQL Vendor-specific SQL Injection"
"SQL Servers SQL Injection Evasion Techniques"
"SQL Servers SQL Injection Evasion Techniques - ver 2"
"SQL Servers Stack Query SQL Injection"
"SQL Servers Time-based SQL Injection"
"SQL Servers Unauthorized SQL Injection Command Execution"
"SQL Servers UNION Query-based SQL Injection"
"Sqlmap Automated SQL Injection tool"
"Squid Proxy strHdrAcptLangGetItem Value Denial of Service"
"Sun Solaris rpc.ypupdated Command Injection"
"SuperFish Adware Root Certificate"
"Suspicious Executable Containing Ransomware"
"Suspicious Executable Mail Attachment"
"Suspicious HTML Mail Phishing Attempt"
"Suspicious JavaScript Web Redirection"
"Suspicious Metadata Mail Phishing Containing Archive Attachment"
"Suspicious Metadata Mail Phishing Redirection"
"Suspicious Microsoft Office File Archive Mail Attachment"
"Symantec Endpoint Protection Manager XML External Entity Denial Of Service"
"Symantec Web Gateway Management Console Remote Shell Command Execution"
"Twiki Unauthenticated Remote Code Execution"
"vBulletin vB_api Remote Code Execution"
"Web Server Exposed Git Repository Information Disclosure"
"Web Servers Malicious Encoding Directory Traversal"
"Web Servers Malicious HTTP Header Directory Traversal"
"Web Servers Malicious Upload Directory Traversal"
"Web Servers Malicious URL Directory Traversal"
"Web Servers Suspicious File Upload"
"WebSphere Server and JBoss Platform Apache Commons Collections Remote Code Execution"
"Windows Browser MFT Crash Bug"
"Wordpress Ajax Store Locator Arbitrary File Download"
"WordPress Captcha Plugin Backdoor"
"WordPress Core Load Script Denial of Service (CVE-2018-6389)"
"WordPress Foxypress Plugin Unrestricted File Upload"
"WordPress Infusionsoft Gravity Forms Add-on Plugin Unrestricted File Upload"
"Wordpress Reflex Gallery Plugin Arbitrary File Upload"
"WordPress Sensitive System Files Information Disclosure"
"WordPress Simple Backup Plugin Unauthorized File Access"
"WordPress Slider Revolution Plugin Local File Inclusion"
"WordPress Slider Revolution Plugin Remote File Inclusion"
"WordPress Statistics Cross Site Scripting"
"WordPress Statistics Plugin SQL Injection"
"WordPress Suspicious File Upload"
"WordPress VisitorTracker JavaScript Function Injection"
"WordPress WP Hide And Security Enhancer Plugin Arbitrary File Download"
"WPScan WordPress Security Scanner"
"Zend PHP Auto Loading Mechanism Local File Inclusion"
"ZmEu Security Scanner"
"Angler Exploit Kit Landing Page"
"Angler Exploit Kit Landing Page Patterns"
"Basilic diff.php Arbitrary Command Execution"
"Cisco Prime Data Center Network Manager processImageSave.jsp Arbitrary File Upload"
"EMC AlphaStor Device Manager Buffer Overflow - High Confidence"
"EMC AlphaStor Device Manager Format String - High Confidence"
"HP Data Protector Backup Client Service GET_FILE Buffer Overflow"
"HP Data Protector Client EXEC_CMD Command Execution"
"HP Data Protector CRS Multiple Opcodes Stack Buffer Overflow"
"HP Data Protector CRS Multiple Stack Buffer Overflows"
"HP Data Protector CRS Opcode 1091 Stack Buffer Overflow"
"HP Data Protector CRS Opcode 1092 Stack Buffer Overflow"
"HP Data Protector CRS Opcode 211 Stack Buffer Overflow"
"HP Data Protector CRS Opcode 215 and 263 Stack Buffer Overflow"
"HP Data Protector CRS Opcode 227 Stack Buffer Overflow"
"HP Data Protector CRS Opcode 234 Stack Buffer Overflow"
"HP Data Protector CRS Opcode 235 Stack Buffer Overflow"
"HP Data Protector CRS Opcode 259 Stack Buffer Overflow"
"HP Data Protector CRS Opcode 260 Stack Buffer Overflow"
"HP Data Protector CRS Opcode 264 Stack Buffer Overflow"
"HP Data Protector CRS Opcode 305 Stack Buffer Overflow"
"HP Data Protector EXEC_BAR Command Execution"
"HP Data Protector Express DtbClsLogin Stack Buffer Overflow"
"HP Data Protector Express Multiple Opcode Parsing Stack Buffer Overflow"
"HP Data Protector Manager MMD Service Stack Buffer Overflow - Improved Performance"
"HP Data Protector Manager RDS Denial of Service"
"HP Data Protector Media Operations Directory Traversal"
"HP Data Protector Opcode 1091 Directory Traversal"
"HP Data Protector Opcode 305 Directory Traversal"
"HP Data Protector Opcode 42 Directory Traversal"
"HP Data Protector Opcode 45 and 46 Code Execution"
"Internet Explorer onCellChange Event Memory Corruption (MS11-003)"
"JavaScript String Dissection Evasion"
"JavaScript String Inflation Evasion"
"ManageEngine Desktop Central StatusUpdate Arbitrary File Upload"
"ManageEngine EventLog Analyzer agentUpload Directory Traversal"
"Microsoft Windows DNS Insufficient Socket Entropy (MS08-037) - High Confidence"
"Microsoft Windows Media Decompression Remote Code Execution (MS13-011)"
"Microsoft Windows Media Player MIDI Code Execution (MS12-004)"
"Microsoft Word PlfLfo Structure Memory Corruption (MS08-072)"
"NFR Agent Heap Overflow"
"Port Overflow"
"Visual Mining NetCharts Server Admin Console Arbitrary File Upload"
"WordPress Slimstat Plugin SQL Injection"
)

## Loop through the above array, execute mgmt_cli command to set threat protection profiles with the desired values using the session ID that was stored during login in sid.txt
for i in "${arr[@]}"
do
    mgmt_cli set threat-protection name "$i" overrides.1.profile "$THREAT_PROFILE" overrides.1.action "Prevent" overrides.1.track "Log" overrides.1.capture-packets true --version 1.3 --format json -s sid.txt
done

# Publish the session
mgmt_cli publish -s sid.txt

# Logout of the session
mgmt_cli logout -s sid.txt