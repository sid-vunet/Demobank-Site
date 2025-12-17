<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%
    // Left navigation panel - Functions menu tree
    String currentFunction = request.getParameter("function");
    if (currentFunction == null) currentFunction = "";
%>
<div class="finacle-leftmenu" style="width: 250px; background-color: #f9f9f9; border-right: 1px solid #ccc; height: 100%; overflow-y: auto; font-family: Arial, sans-serif; font-size: 11px;">
    <div style="background-color: #4a90e2; color: white; padding: 8px; font-weight: bold; font-size: 12px; border-bottom: 2px solid #2e5f9e;">
        <img src="<%=request.getContextPath()%>/ui/images/folder_icon.gif" style="vertical-align: middle; margin-right: 5px;" alt="Functions" />
        Functions
        <span style="float: right; cursor: pointer;" onclick="toggleMenu('allFunctions')">
            <img src="<%=request.getContextPath()%>/ui/images/close_icon.gif" id="closeIcon" style="width: 14px; height: 14px;" alt="Close" />
        </span>
    </div>
    
    <!-- CIF Retail Section -->
    <div class="menu-section" style="margin-top: 5px;">
        <div class="menu-header" onclick="toggleSubmenu('cifRetail')" style="background-color: #e0e8f0; padding: 5px 8px; cursor: pointer; border-bottom: 1px solid #ccc; font-weight: bold;">
            <img src="<%=request.getContextPath()%>/ui/images/folder_closed.gif" id="cifRetailIcon" style="width: 16px; height: 16px; vertical-align: middle; margin-right: 5px;" alt="Folder" />
            CIF Retail
        </div>
        <div id="cifRetailMenu" style="display: <%= currentFunction.startsWith("cifRetail") ? "block" : "none" %>; background-color: #fff; padding-left: 25px;">
            <div class="menu-item" onclick="loadContent('auditTrail')" style="padding: 4px 8px; cursor: pointer; border-bottom: 1px dotted #eee;">
                <img src="<%=request.getContextPath()%>/ui/images/document.gif" style="width: 14px; height: 14px; vertical-align: middle; margin-right: 5px;" alt="Doc" />
                Audit Trail
            </div>
            <div class="menu-item" onclick="loadContent('editEntity')" style="padding: 4px 8px; cursor: pointer; border-bottom: 1px dotted #eee;">
                <img src="<%=request.getContextPath()%>/ui/images/document.gif" style="width: 14px; height: 14px; vertical-align: middle; margin-right: 5px;" alt="Doc" />
                Edit Entity
            </div>
            <div class="menu-item" onclick="loadContent('entityQueue')" style="padding: 4px 8px; cursor: pointer; border-bottom: 1px dotted #eee;">
                <img src="<%=request.getContextPath()%>/ui/images/document.gif" style="width: 14px; height: 14px; vertical-align: middle; margin-right: 5px;" alt="Doc" />
                Entity Queue
            </div>
            <div class="menu-item" onclick="loadContent('newEntity')" style="padding: 4px 8px; cursor: pointer; border-bottom: 1px dotted #eee;">
                <img src="<%=request.getContextPath()%>/ui/images/document.gif" style="width: 14px; height: 14px; vertical-align: middle; margin-right: 5px;" alt="Doc" />
                New Entity
            </div>
            <div class="menu-item" onclick="loadContent('operations')" style="padding: 4px 8px; cursor: pointer; border-bottom: 1px dotted #eee;">
                <img src="<%=request.getContextPath()%>/ui/images/document.gif" style="width: 14px; height: 14px; vertical-align: middle; margin-right: 5px;" alt="Doc" />
                Operations
            </div>
            <div class="menu-item" onclick="loadContent('relationshipManager')" style="padding: 4px 8px; cursor: pointer; border-bottom: 1px dotted #eee;">
                <img src="<%=request.getContextPath()%>/ui/images/document.gif" style="width: 14px; height: 14px; vertical-align: middle; margin-right: 5px;" alt="Doc" />
                Relationship Manager Maintenance
            </div>
        </div>
    </div>
    
    <!-- CIF Corporate Section -->
    <div class="menu-section" style="margin-top: 2px;">
        <div class="menu-header" onclick="toggleSubmenu('cifCorporate')" style="background-color: #e0e8f0; padding: 5px 8px; cursor: pointer; border-bottom: 1px solid #ccc; font-weight: bold;">
            <img src="<%=request.getContextPath()%>/ui/images/folder_closed.gif" id="cifCorporateIcon" style="width: 16px; height: 16px; vertical-align: middle; margin-right: 5px;" alt="Folder" />
            CIF Corporate
        </div>
        <div id="cifCorporateMenu" style="display: <%= currentFunction.startsWith("cifCorporate") ? "block" : "none" %>; background-color: #fff; padding-left: 25px;">
            <div class="menu-item" onclick="loadContent('corpAuditTrail')" style="padding: 4px 8px; cursor: pointer; border-bottom: 1px dotted #eee;">
                <img src="<%=request.getContextPath()%>/ui/images/document.gif" style="width: 14px; height: 14px; vertical-align: middle; margin-right: 5px;" alt="Doc" />
                Audit Trail
            </div>
            <div class="menu-item" onclick="loadContent('corpEditEntity')" style="padding: 4px 8px; cursor: pointer; border-bottom: 1px dotted #eee;">
                <img src="<%=request.getContextPath()%>/ui/images/document.gif" style="width: 14px; height: 14px; vertical-align: middle; margin-right: 5px;" alt="Doc" />
                Edit Entity
            </div>
            <div class="menu-item" onclick="loadContent('corpEntityQueue')" style="padding: 4px 8px; cursor: pointer; border-bottom: 1px dotted #eee;">
                <img src="<%=request.getContextPath()%>/ui/images/document.gif" style="width: 14px; height: 14px; vertical-align: middle; margin-right: 5px;" alt="Doc" />
                Entity Queue
            </div>
            <div class="menu-item" onclick="loadContent('groupMapping')" style="padding: 4px 8px; cursor: pointer; border-bottom: 1px dotted #eee;">
                <img src="<%=request.getContextPath()%>/ui/images/document.gif" style="width: 14px; height: 14px; vertical-align: middle; margin-right: 5px;" alt="Doc" />
                Group Mapping
            </div>
            <div class="menu-item" onclick="loadContent('corpNewEntity')" style="padding: 4px 8px; cursor: pointer; border-bottom: 1px dotted #eee;">
                <img src="<%=request.getContextPath()%>/ui/images/document.gif" style="width: 14px; height: 14px; vertical-align: middle; margin-right: 5px;" alt="Doc" />
                New Entity
            </div>
            <div class="menu-item" onclick="loadContent('corpOperations')" style="padding: 4px 8px; cursor: pointer; border-bottom: 1px dotted #eee;">
                <img src="<%=request.getContextPath()%>/ui/images/document.gif" style="width: 14px; height: 14px; vertical-align: middle; margin-right: 5px;" alt="Doc" />
                Operations
            </div>
            <div class="menu-item" onclick="loadContent('corpRelationshipManager')" style="padding: 4px 8px; cursor: pointer; border-bottom: 1px dotted #eee;">
                <img src="<%=request.getContextPath()%>/ui/images/document.gif" style="width: 14px; height: 14px; vertical-align: middle; margin-right: 5px;" alt="Doc" />
                Relationship Manager Maintenance
            </div>
        </div>
    </div>
    
    <!-- Navigation Controls -->
    <div style="padding: 10px; text-align: center; border-top: 1px solid #ccc; margin-top: 10px;">
        <button onclick="scrollMenu('up')" style="width: 30px; height: 20px; background-color: #e0e8f0; border: 1px solid #999; cursor: pointer;">◄</button>
        <span style="display: inline-block; width: 100px; height: 8px; background-color: #ddd; border: 1px solid #999; vertical-align: middle; position: relative;">
            <span id="scrollIndicator" style="position: absolute; left: 0; top: 0; height: 100%; width: 30%; background-color: #4a90e2;"></span>
        </span>
        <button onclick="scrollMenu('down')" style="width: 30px; height: 20px; background-color: #e0e8f0; border: 1px solid #999; cursor: pointer;">►</button>
    </div>
</div>

<style>
.menu-item:hover {
    background-color: #e8f0ff !important;
    font-weight: bold;
}
.menu-header:hover {
    background-color: #d0dced !important;
}
</style>

<script>
function toggleSubmenu(menuId) {
    var menu = document.getElementById(menuId + 'Menu');
    var icon = document.getElementById(menuId + 'Icon');
    
    if (menu.style.display === 'none') {
        menu.style.display = 'block';
        icon.src = '<%=request.getContextPath()%>/ui/images/folder_open.gif';
    } else {
        menu.style.display = 'none';
        icon.src = '<%=request.getContextPath()%>/ui/images/folder_closed.gif';
    }
}

function loadContent(functionName) {
    // Load content in main area
    window.parent.loadFunction(functionName);
}

function scrollMenu(direction) {
    var container = document.querySelector('.finacle-leftmenu');
    if (direction === 'down') {
        container.scrollTop += 100;
    } else {
        container.scrollTop -= 100;
    }
}
</script>
