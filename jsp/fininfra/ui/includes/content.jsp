<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%
    // Content area - Dynamic content based on selected function
    String currentFunction = request.getParameter("function");
    if (currentFunction == null) currentFunction = "welcome";
    String username = (String) session.getAttribute("username");
%>
<div class="finacle-content" style="padding: 20px; font-family: Arial, sans-serif; font-size: 12px; background-color: #ffffff; height: 100%; overflow-y: auto;">
    
    <% if ("welcome".equals(currentFunction)) { %>
        <!-- Welcome Screen -->
        <div style="text-align: center; margin-top: 50px;">
            <h2 style="color: #2e5f9e; font-size: 24px; margin-bottom: 20px;">
                Welcome to Finacle Universal Banking Solution
            </h2>
            <p style="font-size: 14px; color: #666; max-width: 600px; margin: 0 auto; line-height: 1.6;">
                Hello <strong><%= username != null ? username : "User" %></strong>,<br/><br/>
                You are logged into the FININFRA solution. Please select a function from the left menu to begin.
            </p>
            
            <div style="margin-top: 40px; text-align: left; max-width: 800px; margin-left: auto; margin-right: auto;">
                <h3 style="color: #2e5f9e; border-bottom: 2px solid #4a90e2; padding-bottom: 5px;">Quick Access</h3>
                <table border="0" cellspacing="10" cellpadding="10" style="margin-top: 20px; width: 100%;">
                    <tr>
                        <td style="background-color: #f0f8ff; border: 1px solid #ccc; padding: 15px; border-radius: 5px; cursor: pointer;" onclick="loadFunction('auditTrail')">
                            <strong style="color: #2e5f9e;">📋 Audit Trail</strong><br/>
                            <span style="font-size: 11px; color: #666;">View transaction audit logs</span>
                        </td>
                        <td style="background-color: #f0f8ff; border: 1px solid #ccc; padding: 15px; border-radius: 5px; cursor: pointer;" onclick="loadFunction('editEntity')">
                            <strong style="color: #2e5f9e;">✏️ Edit Entity</strong><br/>
                            <span style="font-size: 11px; color: #666;">Modify existing customer records</span>
                        </td>
                        <td style="background-color: #f0f8ff; border: 1px solid #ccc; padding: 15px; border-radius: 5px; cursor: pointer;" onclick="loadFunction('newEntity')">
                            <strong style="color: #2e5f9e;">➕ New Entity</strong><br/>
                            <span style="font-size: 11px; color: #666;">Create new customer entity</span>
                        </td>
                    </tr>
                    <tr>
                        <td style="background-color: #f0f8ff; border: 1px solid #ccc; padding: 15px; border-radius: 5px; cursor: pointer;" onclick="loadFunction('entityQueue')">
                            <strong style="color: #2e5f9e;">📑 Entity Queue</strong><br/>
                            <span style="font-size: 11px; color: #666;">View pending entity approvals</span>
                        </td>
                        <td style="background-color: #f0f8ff; border: 1px solid #ccc; padding: 15px; border-radius: 5px; cursor: pointer;" onclick="loadFunction('operations')">
                            <strong style="color: #2e5f9e;">⚙️ Operations</strong><br/>
                            <span style="font-size: 11px; color: #666;">Perform banking operations</span>
                        </td>
                        <td style="background-color: #f0f8ff; border: 1px solid #ccc; padding: 15px; border-radius: 5px; cursor: pointer;" onclick="loadFunction('reports')">
                            <strong style="color: #2e5f9e;">📊 Reports</strong><br/>
                            <span style="font-size: 11px; color: #666;">Generate system reports</span>
                        </td>
                    </tr>
                </table>
            </div>
            
            <div style="margin-top: 40px; padding: 15px; background-color: #fffacd; border: 1px solid #ffd700; border-radius: 5px; max-width: 800px; margin-left: auto; margin-right: auto;">
                <strong>⚠️ System Notice:</strong><br/>
                <span style="font-size: 11px;">
                    (1st October, i.e. Wednesday's Presentation): 2. Presentation : 11 AM to 3 PM (Special Clearing)<br/>
                    Please ensure all transactions are completed before the maintenance window.
                </span>
            </div>
        </div>
    
    <% } else if ("auditTrail".equals(currentFunction)) { %>
        <!-- Audit Trail Function -->
        <h2 style="color: #2e5f9e; border-bottom: 2px solid #4a90e2; padding-bottom: 8px;">CIF Retail - Audit Trail</h2>
        <div style="margin-top: 20px; padding: 15px; background-color: #f9f9f9; border: 1px solid #ddd;">
            <form>
                <table border="0" cellspacing="8" cellpadding="5">
                    <tr>
                        <td><strong>Customer ID:</strong></td>
                        <td><input type="text" name="custId" style="width: 200px; padding: 4px; border: 1px solid #999;" /></td>
                        <td><strong>From Date:</strong></td>
                        <td><input type="date" name="fromDate" style="width: 150px; padding: 4px; border: 1px solid #999;" /></td>
                    </tr>
                    <tr>
                        <td><strong>Account Number:</strong></td>
                        <td><input type="text" name="accountNo" style="width: 200px; padding: 4px; border: 1px solid #999;" /></td>
                        <td><strong>To Date:</strong></td>
                        <td><input type="date" name="toDate" style="width: 150px; padding: 4px; border: 1px solid #999;" /></td>
                    </tr>
                    <tr>
                        <td><strong>Transaction Type:</strong></td>
                        <td>
                            <select name="txnType" style="width: 210px; padding: 4px; border: 1px solid #999;">
                                <option value="">All Types</option>
                                <option value="CREATE">Create</option>
                                <option value="MODIFY">Modify</option>
                                <option value="DELETE">Delete</option>
                            </select>
                        </td>
                        <td colspan="2">
                            <button type="submit" style="padding: 6px 20px; background-color: #4a90e2; color: white; border: none; cursor: pointer; font-weight: bold;">Search</button>
                            <button type="reset" style="padding: 6px 20px; background-color: #999; color: white; border: none; cursor: pointer; margin-left: 10px;">Clear</button>
                        </td>
                    </tr>
                </table>
            </form>
        </div>
        
        <div style="margin-top: 20px;">
            <h3 style="color: #2e5f9e;">Search Results</h3>
            <table border="1" cellspacing="0" cellpadding="8" style="width: 100%; border-collapse: collapse; font-size: 11px;">
                <thead style="background-color: #4a90e2; color: white;">
                    <tr>
                        <th>Timestamp</th>
                        <th>Customer ID</th>
                        <th>Account No</th>
                        <th>Transaction Type</th>
                        <th>User</th>
                        <th>Details</th>
                    </tr>
                </thead>
                <tbody>
                    <tr>
                        <td colspan="6" align="center" style="padding: 20px; color: #999;">
                            No records found. Please enter search criteria and click Search.
                        </td>
                    </tr>
                </tbody>
            </table>
        </div>
    
    <% } else if ("editEntity".equals(currentFunction)) { %>
        <!-- Edit Entity Function -->
        <h2 style="color: #2e5f9e; border-bottom: 2px solid #4a90e2; padding-bottom: 8px;">CIF Retail - Edit Entity</h2>
        <div style="margin-top: 20px; padding: 15px; background-color: #f9f9f9; border: 1px solid #ddd;">
            <form>
                <table border="0" cellspacing="8" cellpadding="5" style="width: 100%;">
                    <tr>
                        <td width="150"><strong>Customer ID:</strong></td>
                        <td><input type="text" name="custId" style="width: 250px; padding: 4px; border: 1px solid #999;" required /></td>
                        <td>
                            <button type="button" onclick="searchCustomer()" style="padding: 6px 20px; background-color: #4a90e2; color: white; border: none; cursor: pointer;">Search</button>
                        </td>
                    </tr>
                </table>
            </form>
        </div>
        
        <div id="customerDetails" style="margin-top: 20px; padding: 15px; background-color: #ffffff; border: 1px solid #ddd; display: none;">
            <h3 style="color: #2e5f9e;">Customer Details</h3>
            <table border="0" cellspacing="8" cellpadding="5" style="width: 100%;">
                <tr>
                    <td width="150"><strong>Full Name:</strong></td>
                    <td><input type="text" id="custName" style="width: 300px; padding: 4px; border: 1px solid #999;" /></td>
                    <td width="150"><strong>Date of Birth:</strong></td>
                    <td><input type="date" id="dob" style="width: 200px; padding: 4px; border: 1px solid #999;" /></td>
                </tr>
                <tr>
                    <td><strong>Email:</strong></td>
                    <td><input type="email" id="email" style="width: 300px; padding: 4px; border: 1px solid #999;" /></td>
                    <td><strong>Phone:</strong></td>
                    <td><input type="tel" id="phone" style="width: 200px; padding: 4px; border: 1px solid #999;" /></td>
                </tr>
                <tr>
                    <td><strong>Address:</strong></td>
                    <td colspan="3"><textarea id="address" rows="3" style="width: 95%; padding: 4px; border: 1px solid #999;"></textarea></td>
                </tr>
                <tr>
                    <td colspan="4" align="center" style="padding-top: 15px;">
                        <button type="button" style="padding: 8px 30px; background-color: #28a745; color: white; border: none; cursor: pointer; font-weight: bold;">Update</button>
                        <button type="button" style="padding: 8px 30px; background-color: #dc3545; color: white; border: none; cursor: pointer; margin-left: 10px;">Cancel</button>
                    </td>
                </tr>
            </table>
        </div>
    
    <% } else { %>
        <!-- Default content for other functions -->
        <h2 style="color: #2e5f9e; border-bottom: 2px solid #4a90e2; padding-bottom: 8px;">
            Function: <%= currentFunction %>
        </h2>
        <div style="margin-top: 20px; padding: 20px; background-color: #f9f9f9; border: 1px solid #ddd;">
            <p>This function is under development.</p>
            <p>Function ID: <strong><%= currentFunction %></strong></p>
            <p>User: <strong><%= username %></strong></p>
        </div>
    <% } %>
    
</div>

<script>
function loadFunction(funcName) {
    window.location.href = '<%=request.getContextPath()%>/fininfra/ui/SSOLogin.jsp?view=home&function=' + funcName;
}

function searchCustomer() {
    // Show customer details section
    document.getElementById('customerDetails').style.display = 'block';
    // Populate with dummy data for demo
    document.getElementById('custName').value = 'John Doe';
    document.getElementById('dob').value = '1985-06-15';
    document.getElementById('email').value = 'john.doe@example.com';
    document.getElementById('phone').value = '+91 9876543210';
    document.getElementById('address').value = '123 Main Street, Mumbai, Maharashtra 400001';
}

function executeShortcut() {
    var shortcut = document.getElementById('menuShortcut').value;
    if (shortcut) {
        alert('Executing menu shortcut: ' + shortcut);
        // Load corresponding function
    }
}
</script>
