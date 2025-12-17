<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%
    // Banner section - Finacle logo and icon buttons
    String contextPath = request.getContextPath();
    String customerCall = "None";
    String consortCall = "None";
    String repStatus = "Non-Telephony Rep";
    String currentDate = new java.text.SimpleDateFormat("MM/dd/yyyy").format(new java.util.Date());
%>
<div class="finacle-banner" style="background: linear-gradient(to bottom, #4a90e2 0%, #2e5f9e 100%); padding: 8px 10px; border-bottom: 2px solid #1e4d7b;">
    <table width="100%" border="0" cellspacing="0" cellpadding="0">
        <tr>
            <td width="200" align="left" style="vertical-align: middle;">
                <!-- Finacle Logo -->
                <div style="display: inline-block; background-color: white; padding: 5px 15px; border-radius: 3px;">
                    <span style="color: #cc0000; font-size: 24px; font-weight: bold; font-family: 'Times New Roman', serif;">
                        <span style="color: #cc0000;">r</span> Finacle<sup style="font-size: 10px;">®</sup>
                    </span>
                    <div style="color: #333; font-size: 8px; margin-top: -2px; letter-spacing: 1px;">
                        Universal Banking Solution from Infosys
                    </div>
                </div>
            </td>
            <td align="center" style="vertical-align: middle;">
                <!-- Icon Buttons -->
                <table border="0" cellspacing="5" cellpadding="0" style="margin: 0 auto;">
                    <tr>
                        <td align="center">
                            <img src="<%=contextPath%>/ui/images/home_icon.gif" alt="Home" title="Home" style="cursor: pointer; width: 32px; height: 32px;" onclick="location.href='<%=contextPath%>/fininfra/ui/SSOLogin.jsp?view=home'" />
                        </td>
                        <td align="center">
                            <img src="<%=contextPath%>/ui/images/profile_icon.gif" alt="Profile" title="User Profile" style="cursor: pointer; width: 32px; height: 32px;" />
                        </td>
                        <td align="center">
                            <img src="<%=contextPath%>/ui/images/messages_icon.gif" alt="Messages" title="Messages" style="cursor: pointer; width: 32px; height: 32px;" />
                        </td>
                        <td align="center">
                            <img src="<%=contextPath%>/ui/images/email_icon.gif" alt="Email" title="Email" style="cursor: pointer; width: 32px; height: 32px;" />
                        </td>
                        <td align="center">
                            <img src="<%=contextPath%>/ui/images/calculator_icon.gif" alt="Calculator" title="Calculator" style="cursor: pointer; width: 32px; height: 32px;" />
                        </td>
                        <td align="center">
                            <img src="<%=contextPath%>/ui/images/notepad_icon.gif" alt="Notepad" title="Notepad" style="cursor: pointer; width: 32px; height: 32px;" />
                        </td>
                    </tr>
                </table>
            </td>
            <td width="350" align="right" style="vertical-align: middle; color: white; font-size: 11px; font-family: Arial, sans-serif;">
                <table border="0" cellspacing="0" cellpadding="2" style="color: white;">
                    <tr>
                        <td align="right"><strong>Customer Call:</strong></td>
                        <td align="left"><%= customerCall %></td>
                    </tr>
                    <tr>
                        <td align="right"><strong>Consort Call:</strong></td>
                        <td align="left"><%= consortCall %></td>
                    </tr>
                    <tr>
                        <td align="right"><strong>Rep Status:</strong></td>
                        <td align="left"><%= repStatus %></td>
                    </tr>
                    <tr>
                        <td align="right" colspan="2">
                            <img src="<%=contextPath%>/ui/images/infosys_logo.gif" alt="Infosys" style="height: 18px; vertical-align: middle;" />
                        </td>
                    </tr>
                </table>
            </td>
        </tr>
    </table>
</div>

<!-- Menu Bar - Below Banner -->
<div class="finacle-menubar" style="background-color: #f5f5f5; border-bottom: 1px solid #ccc; padding: 3px 10px; font-size: 11px; font-family: Arial, sans-serif;">
    <table width="100%" border="0" cellspacing="0" cellpadding="0">
        <tr>
            <td align="right" style="color: #333;">
                <strong><%= currentDate %></strong>
                <span style="margin: 0 10px;">|</span>
                <strong>Menu Shortcut:</strong>
                <input type="text" id="menuShortcut" style="width: 150px; font-size: 11px; padding: 2px; border: 1px solid #999;" placeholder="Enter shortcut..." />
                <button onclick="executeShortcut()" style="font-size: 11px; padding: 2px 8px; margin-left: 5px;">Go</button>
            </td>
        </tr>
    </table>
</div>
