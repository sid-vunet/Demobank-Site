<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%
    // Header section - User info, Calendar, Timezone
    String currentUser = (String) session.getAttribute("username");
    if (currentUser == null) currentUser = "Guest";
    String sessionSolution = (String) session.getAttribute("solution");
    if (sessionSolution == null) sessionSolution = "CRM";
%>
<div class="finacle-header" style="background-color: #e8e8e8; border-bottom: 1px solid #ccc; padding: 5px 10px; font-family: Arial, sans-serif; font-size: 11px;">
    <table width="100%" border="0" cellspacing="0" cellpadding="0">
        <tr>
            <td align="left" style="vertical-align: middle;">
                <span style="font-weight: bold; margin-right: 10px;">User: <%= currentUser %></span>
                <select id="solutionDropdown" style="font-size: 11px; padding: 2px; border: 1px solid #999;">
                    <option value="Select">Select</option>
                    <option value="CRM" <%= "CRM".equals(sessionSolution) ? "selected" : "" %>>CRM</option>
                    <option value="CoreServer">CoreServer</option>
                    <option value="FIPAdministrator">FIPAdministrator</option>
                    <option value="FININFRA" selected>FININFRA</option>
                    <option value="GBM">GBM</option>
                </select>
            </td>
            <td align="center" style="vertical-align: middle;">
                <span style="color: #cc0000; font-weight: bold; font-size: 12px;">
                    (1st October, i.e. Wednesday's Presentation): 2. Presentation : 11 AM to 3 PM (Special Clearing)
                </span>
            </td>
            <td align="right" style="vertical-align: middle; white-space: nowrap;">
                <span style="margin-right: 15px;"><strong>Calendar:</strong> 
                    <select style="font-size: 11px; padding: 2px; border: 1px solid #999;">
                        <option value="Gregorian" selected>Gregorian</option>
                        <option value="Islamic">Islamic</option>
                    </select>
                </span>
                <span style="margin-right: 15px;"><strong>Time Zone:</strong> IST</span>
                <img src="<%=request.getContextPath()%>/ui/images/search.gif" alt="Search" style="vertical-align: middle; margin-right: 10px; cursor: pointer;" />
                <span style="margin-right: 5px;"><strong>Solution:</strong></span>
            </td>
        </tr>
    </table>
</div>
