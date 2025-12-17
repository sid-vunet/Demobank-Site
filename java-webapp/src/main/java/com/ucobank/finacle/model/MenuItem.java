package com.ucobank.finacle.model;

import java.io.Serializable;
import java.util.ArrayList;
import java.util.List;

/**
 * MenuItem model - Represents a menu item in the navigation tree
 */
public class MenuItem implements Serializable {
    private static final long serialVersionUID = 1L;
    
    private String id;
    private String name;
    private String icon;
    private String functionId;
    private boolean expandable;
    private boolean expanded;
    private List<MenuItem> children;

    public MenuItem() {
        this.children = new ArrayList<>();
    }

    public MenuItem(String id, String name, String functionId) {
        this.id = id;
        this.name = name;
        this.functionId = functionId;
        this.expandable = false;
        this.children = new ArrayList<>();
    }

    public MenuItem(String id, String name, boolean expandable) {
        this.id = id;
        this.name = name;
        this.expandable = expandable;
        this.children = new ArrayList<>();
    }

    // Add child menu item
    public void addChild(MenuItem child) {
        this.children.add(child);
        this.expandable = true;
    }

    // Getters and Setters
    public String getId() {
        return id;
    }

    public void setId(String id) {
        this.id = id;
    }

    public String getName() {
        return name;
    }

    public void setName(String name) {
        this.name = name;
    }

    public String getIcon() {
        return icon;
    }

    public void setIcon(String icon) {
        this.icon = icon;
    }

    public String getFunctionId() {
        return functionId;
    }

    public void setFunctionId(String functionId) {
        this.functionId = functionId;
    }

    public boolean isExpandable() {
        return expandable;
    }

    public void setExpandable(boolean expandable) {
        this.expandable = expandable;
    }

    public boolean isExpanded() {
        return expanded;
    }

    public void setExpanded(boolean expanded) {
        this.expanded = expanded;
    }

    public List<MenuItem> getChildren() {
        return children;
    }

    public void setChildren(List<MenuItem> children) {
        this.children = children;
    }
}
