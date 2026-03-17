-- Markdown Editor Page
SELECT 'shell' AS component,
       'Markdown Editor' AS title,
       'logo.png' AS image,
       '/' AS link,
       'Rahul Raj' AS user_name,
       true AS fluid,
       json_array(
           json_object('title', 'Generator',        'link', 'entries.sql',  'icon', 'pencil'),
           json_object('title', 'Markdown Editor',  'link', 'md_editor.sql','icon', 'file-text', 'active', true),
           json_object('title', 'Settings',         'link', 'settings.sql', 'icon', 'settings')
       ) AS menu_item,
        json_array(
            '/js/layout.js?v=' || CAST(STRFTIME('%s', 'now') AS TEXT),
            '/js/chat.js?v='   || CAST(STRFTIME('%s', 'now') AS TEXT),
            'https://cdnjs.cloudflare.com/ajax/libs/jszip/3.10.1/jszip.min.js',
            '/js/pikaday.js',
            '/js/md-date-picker.js?v=' || CAST(STRFTIME('%s', 'now') AS TEXT),
            '/js/md-parser.js?v=' || CAST(STRFTIME('%s', 'now') AS TEXT),
            '/js/results.js?v=' || CAST(STRFTIME('%s', 'now') AS TEXT),
            '/js/md-editor-core.js?v=' || CAST(STRFTIME('%s', 'now') AS TEXT)
        ) AS javascript,
        json_array(
            '/css/theme.css?v=' || CAST(STRFTIME('%s', 'now') AS TEXT),
            '/css/chat.css?v='  || CAST(STRFTIME('%s', 'now') AS TEXT),
            '/css/pikaday.css'
        ) AS css;

SET _members   = (SELECT json_group_array(json_object('name', full_name, 'id', id)) FROM team_members);
SET _scenarios = (SELECT json_group_array(name) FROM scenario_types);
SET _execs     = (SELECT json_group_array(name) FROM execution_types);
SET _statuses  = (SELECT json_group_array(name) FROM test_case_statuses);

-- CSP-safe: inject master data as data-* attributes on a hidden element (no inline script)
SELECT 'html' AS component,
    '<div id="qfme-config" hidden'
    || ' data-members=''' || REPLACE(COALESCE($_members,'[]'), '''', '&apos;') || ''''
    || ' data-scenarios=''' || REPLACE(COALESCE($_scenarios,'[]'), '''', '&apos;') || ''''
    || ' data-execs=''' || REPLACE(COALESCE($_execs,'[]'), '''', '&apos;') || ''''
    || ' data-statuses=''' || REPLACE(COALESCE($_statuses,'[]'), '''', '&apos;') || ''''
    || '></div>' AS html;

SELECT 'html' AS component, '
<div id="qfme-root">
    <style>
        .editor-container {
            display: flex;
            min-height: calc(100vh - 140px);
            width: 100%;
        }

        /* Top Dock Toolbar Styles */
        .action-dock-container {
            width: 100%;
            display: none; /* Toggled by JS */
            padding: 0.5rem 1rem;
            background: rgba(248, 250, 252, 0.9);
            border-bottom: 1px solid var(--border-color);
            z-index: 50;
            position: sticky;
            top: 0;
            justify-content: flex-end; /* Align right */
            padding-right: 2rem;       /* Add some spacing from the edge */
        }
        .action-dock-container.visible {
            display: flex;
            animation: slideDown 0.3s ease;
        }

        @keyframes slideDown {
            from { opacity: 0; transform: translateY(-10px); }
            to { opacity: 1; transform: translateY(0); }
        }

        .action-dock {
            /* Pill style maintained */
            background: #fff;
            border: 1px solid var(--border-color);
            border-radius: 8px;
            padding: 8px 16px; /* Bigger padding */
            box-shadow: 0 2px 6px rgba(0,0,0,0.05);
            display: flex;
            align-items: center;
            gap: 1rem;
        }

        /* Reuse existing dock styles */
        .dock-section { display: flex; align-items: center; }
        .dock-section.gap-2 { gap: 0.5rem; }
        .dock-section.border-r { border-right: 1px solid #e2e8f0; padding-right: 1rem; margin-right: 0.5rem; }
        .dock-checkbox { width: 1.1rem; height: 1.1rem; accent-color: var(--primary-color); cursor: pointer; margin-right: 0.5rem; }
        .dock-label { font-weight: 600; font-size: 0.9rem; color: var(--text-primary); cursor: pointer; white-space: nowrap; }
        .dock-count { font-size: 0.8rem; color: var(--text-muted); margin-left: 0.5rem; background: #f1f5f9; padding: 0.1rem 0.4rem; border-radius: 999px; white-space: nowrap; }
        
        /* Inputs/Buttons */
        .dock-select, .dock-input, .dock-select-mini, .dock-input-date {
            height: 36px; font-size: 0.9rem; border: 1px solid #cbd5e1; background: #fff; border-radius: 6px; padding: 0 0.5rem; color: #334155; transition: all 0.2s;
        }
        .dock-btn-icon { width: 36px; height: 36px; display: flex; align-items: center; justify-content: center; background: transparent; border: 1px solid transparent; border-radius: 6px; color: #64748b; cursor: pointer; transition: all 0.2s; }
        .dock-btn-icon:hover { background: #f1f5f9; color: var(--primary-color); }
        
        /* Unified Blue Buttons */
        .dock-btn-primary, .dock-btn-secondary, .dock-btn-run { 
            height: 36px; 
            padding: 0 1rem; 
            background: var(--primary-color); 
            border: none; 
            border-radius: 6px; 
            color: white; 
            font-size: 0.9rem; 
            font-weight: 600; 
            cursor: pointer; 
            display: flex; 
            align-items: center; 
            gap: 0.4rem; 
            box-shadow: 0 2px 4px rgba(14, 165, 233, 0.3); 
            transition: all 0.2s;
            margin-left: 0.25rem;
        }
        .dock-btn-primary:hover, .dock-btn-secondary:hover, .dock-btn-run:hover { 
            background: #0284c7; 
            transform: translateY(-1px);
            box-shadow: 0 4px 6px rgba(14, 165, 233, 0.4);
        }

        /* Utility classes */
        .flex { display: flex; }
        .items-center { align-items: center; }
        .justify-between { justify-content: space-between; }
        .gap-1 { gap: 0.25rem; }
        .gap-2 { gap: 0.5rem; }
        .gap-3 { gap: 0.75rem; }
        .gap-4 { gap: 1rem; }
        .w-64 { width: 16rem; }
        .w-56 { width: 14rem; }
        .w-48 { width: 12rem; }
        .w-40 { width: 10rem; }
        .w-32 { width: 8rem; }
        .w-28 { width: 7rem; }
        .w-24 { width: 6rem; }
        .pr-2 { padding-right: 0.5rem; }
        .border-r { border-right: 1px solid var(--border-color); }
        .border-gray-200 { border-color: #e5e7eb; }
        .left-rounded { border-top-right-radius: 0; border-bottom-right-radius: 0; border-right: none; }
        .right-rounded { border-top-left-radius: 0; border-bottom-left-radius: 0; }
        
        /* Tree View (Hierarchy) Tab Styles */
        .tree-node { margin-left: 1.25rem; border-left: 1px solid #e2e8f0; padding-left: 0.75rem; margin-top: 0.25rem; }
        .tree-node.open > .tree-children { display: block; }
        .tree-header { display: flex; align-items: center; justify-content: space-between; padding: 4px 8px; border-radius: 6px; transition: background 0.2s; }
        .tree-header:hover { background: #f8fafc; }
        .tree-actions { display: flex; gap: 0.75rem; opacity: 0.4; transition: opacity 0.2s; }
        .tree-header:hover .tree-actions { opacity: 1; }
        .tree-actions span:hover { text-decoration: underline; }
        .tree-children { display: none; }
        .tree-node.open > .tree-children { display: block; }

        /* Upload Prompt */
        .upload-prompt {
            display: flex;
            flex-direction: column;
            align-items: center;
            justify-content: center;
            width: 100%;
            min-height: calc(100vh - 140px);
            text-align: center;
            padding: 2rem;
        }

        .upload-card {
            background: var(--bg-card);
            border: 1.5px dashed var(--border-color);
            border-radius: 16px;
            padding: 2.5rem 2rem;
            text-align: center;
            width: 280px;
            transition: all 0.2s ease;
            position: relative;
            cursor: pointer;
        }
        .upload-card:hover {
            border-color: var(--primary-color);
            box-shadow: 0 8px 24px rgba(14,165,233,0.12);
            transform: translateY(-4px);
        }
        .upload-card .upload-icon-wrap {
            width: 80px;
            height: 80px;
            border-radius: 20px;
            display: flex;
            align-items: center;
            justify-content: center;
            margin: 0 auto 1.25rem auto;
            font-size: 2.5rem;
        }
        .upload-card h3 {
            font-size: 1.1rem;
            font-weight: 700;
            margin-bottom: 0.5rem;
            color: var(--text-primary);
        }
        .upload-card p {
            color: var(--text-secondary);
            font-size: 0.875rem;
            margin-bottom: 1.5rem;
            line-height: 1.5;
        }
        .upload-card-btn {
            width: 100%;
            padding: 0.625rem 1rem;
            border-radius: 8px;
            font-size: 0.875rem;
            font-weight: 600;
            cursor: pointer;
            display: flex;
            align-items: center;
            justify-content: center;
            gap: 0.5rem;
            border: 1px solid var(--border-color);
            transition: all 0.2s;
        }
        
        .upload-icon {
            font-size: 3rem;
            color: var(--primary-color);
            margin-bottom: 1.5rem;
            opacity: 0.8;
        }

        /* Split Layout */
        #mainEditorArea {
            display: none; /* Hidden strictly until upload */
            width: 100%;
            height: 100%;
            gap: 1rem;
        }

        /* Sidebar Tree */
        .tree-sidebar {
            width: 280px;
            background: var(--bg-card);
            border: 1px solid var(--border-color);
            border-radius: 12px;
            display: flex;
            flex-direction: column;
            overflow: hidden;
            flex-shrink: 0;
        }

        .tree-sidebar .tree-header {
            padding: 1rem;
            border-bottom: 1px solid var(--border-color);
            font-weight: 600;
            color: var(--text-primary);
            background: rgba(255,255,255,0.02);
            display: flex;
            justify-content: space-between;
            align-items: center;
        }

        .tree-content {
            flex: 1;
            overflow: auto; /* Allow both horizontal and vertical scrolling */
            padding: 0.5rem;
            /* Hide vertical scrollbar but keep horizontal if needed? No, user asked for scroll. */
        }

        /* Tree Nodes */
        ul.tree-list {
            list-style: none;
            padding-left: 0.5rem;
            margin: 0;
            min-width: max-content; /* Ensure list takes full width of longest item */
        }
        
        ul.tree-list li {
            margin: 2px 0;
        }
        
        .tree-item-label {
            display: flex;
            align-items: center;
            padding: 6px 8px;
            cursor: pointer;
            border-radius: 6px;
            color: var(--text-secondary);
            font-size: 0.9rem;
            transition: all 0.2s ease;
            white-space: nowrap;
            /* Removed overflow: hidden and text-overflow: ellipsis to show full name */
        }
        
        .tree-item-label:hover {
            background: rgba(14, 165, 233, 0.12);
            color: var(--primary-color);
            transform: translateX(2px);
            box-shadow: 0 2px 4px rgba(0, 0, 0, 0.05);
        }
        
        .tree-item-label.active {
            background: rgba(99, 102, 241, 0.15);
            color: var(--primary-color);
        }
        
        .tree-item-label .icon {
            margin-right: 8px;
            width: 16px;
            text-align: center;
            font-size: 0.85rem;
            transition: transform 0.2s ease;
        }
        
        .tree-item-label:hover .icon {
            transform: scale(1.15);
        }
        
        .tree-children {
            display: none;
            padding-left: 12px;
            margin-left: 6px;
            border-left: 1px solid var(--border-color);
        }
        
        .tree-dir.expanded > .tree-children {
            display: block;
        }

        /* Main Editor/Viewer */
        .editor-main {
            flex: 1;
            background: var(--bg-card);
            border: 1px solid var(--border-color);
            border-radius: 12px;
            display: flex;
            flex-direction: column;
            overflow: hidden;
        }

        .editor-header {
            padding: 1rem 1.5rem;
            border-bottom: 1px solid var(--border-color);
            display: flex;
            justify-content: space-between;
            align-items: center;
            background: rgba(255,255,255,0.02);
        }

        .editor-content-scroll {
            flex: 1;
            overflow-y: auto;
            padding: 0;
        }
        
    /* Base Modal Core CSS */
    .modal-overlay {
        display: none;
        position: fixed;
        inset: 0;
        z-index: 10000;
        background: rgba(15, 23, 42, 0.55);
        backdrop-filter: blur(3px);
        align-items: center;
        justify-content: center;
    }
    .modal-overlay.active { 
        display: flex !important; 
    }
    .md-modal {
        background: #ffffff;
        border-radius: 16px;
        width: 100%;
        max-width: 650px;
        max-height: 90vh;
        display: flex;
        flex-direction: column;
        box-shadow: 0 20px 60px rgba(0,0,0,0.2);
        overflow: hidden;
    }
    .modal-header {
        display: flex;
        align-items: center;
        justify-content: space-between;
        padding: 18px 24px;
        border-bottom: 1px solid #e2e8f0;
        background: linear-gradient(135deg,#f0f7ff,#f8fafc);
    }
    .modal-header h3 { margin: 0; font-size: 1rem; font-weight: 700; color: #1e293b; }
    .close-modal { width: 30px; height: 30px; border: none; border-radius: 8px; background: #f1f5f9; cursor: pointer; display: flex; align-items: center; justify-content: center; color: #64748b; font-size: 1.1rem; }
    .close-modal:hover { background: #fee2e2; color: #dc2626; }
    .modal-body { padding: 20px 24px; overflow-y: auto; flex: 1; }
    .modal-footer { display: flex; justify-content: flex-end; gap: 10px; padding: 14px 24px; border-top: 1px solid #e2e8f0; background: #f8fafc; }
    
    .form-group { margin-bottom: 14px; }
    .form-group label { display: block; font-size: 0.78rem; font-weight: 700; color: #374151; margin-bottom: 4px; }
    .form-input { width: 100%; border: 1.5px solid #e2e8f0; border-radius: 8px; padding: 7px 10px; font-size: 0.85rem; color: #1e293b; background: #fafafa; font-family: inherit; }
    .form-input:focus { outline: none; border-color: #4f46e5; box-shadow: 0 0 0 3px rgba(79,70,229,0.1); }
    textarea.form-input { resize: vertical; }

    /* === Generator-identical bulk toolbar CSS === */
    .qfg-bulk-toolbar{background:#fff;border:1px solid #e2e8f0;border-radius:12px;padding:12px 16px;margin:10px 0 6px;display:flex;flex-direction:column;gap:8px;box-shadow:0 1px 4px rgba(0,0,0,.06)}
    .qfg-bulk-row{display:flex;flex-wrap:nowrap;gap:12px;align-items:center}
    .qfg-bulk-group{display:flex;align-items:center;gap:8px}
    .qfg-bulk-divider{width:1px;height:20px;background:#e2e8f0}
    .qfg-bulk-spacer{flex:1}
    .qfg-bulk-select{padding:4px 8px;border:1px solid #cbd5e1;border-radius:7px;font-size:.8rem;color:#334155;background:#f8fafc;height:32px}
    .qfg-bulk-input{padding:4px 8px;border:1px solid #cbd5e1;border-radius:7px;font-size:.8rem;color:#334155;background:#f8fafc;height:32px}
    .qfg-bulk-label{font-size:.65rem;font-weight:800;text-transform:uppercase;letter-spacing:.05em;color:#64748b;white-space:nowrap}
    .qfg-select-bar{display:flex;align-items:center;gap:10px;padding:8px 14px;background:#f8fafc;border:1px solid #e2e8f0;border-radius:8px;margin-bottom:8px}
    .qfg-select-all-label{display:flex;align-items:center;gap:6px;font-size:.82rem;font-weight:600;color:#334155;cursor:pointer;user-select:none}
    .qfg-select-all-label input[type=checkbox]{width:16px;height:16px;cursor:pointer;accent-color:#2563eb}
    .qfg-sel-count{font-size:.8rem;font-weight:700;color:#2563eb;background:#eff6ff;padding:2px 9px;border-radius:12px}
    .tc-checkbox{width:16px;height:16px;cursor:pointer;accent-color:#2563eb;flex-shrink:0}

        /* Tab Styles */
        .tab-btn.active {
            color: var(--primary-color) !important;
            border-bottom-color: var(--primary-color) !important;
            font-weight: 600;
        }
        .tab-content { display: none !important; }
        .tab-content.active { display: block !important; }

        .sidebar-btn:hover {
            transform: translateY(-1px);
        }

        .save-action-btn:hover {
            background: linear-gradient(135deg,#4338ca,#1d4ed8) !important;
            transform: translateY(-1px);
            box-shadow: 0 5px 14px rgba(79,70,229,0.5) !important;
        }

        #md-save-toast {
            position: fixed;
            bottom: 28px;
        /* Modified Indicator & Badge */
        .modified-indicator { color: #f59e0b; font-weight: 600; font-size: 0.8rem; margin-left: 0.4rem; font-style: italic; }
        .badge { display: inline-flex; align-items: center; padding: 0.15rem 0.5rem; border-radius: 999px; font-size: 0.72rem; font-weight: 700; text-transform: uppercase; background: #f1f5f9; color: #64748b; border: 1px solid #e2e8f0; }

        /* Buttons */
        .btn { display: inline-flex; align-items: center; gap: 0.5rem; padding: 0.6rem 1.25rem; border-radius: 8px; font-size: 0.88rem; font-weight: 600; cursor: pointer; transition: all 0.2s ease; border: 1px solid transparent; line-height: 1.2; }
        .btn-sm { padding: 0.4rem 0.8rem; font-size: 0.75rem; border-radius: 6px; }
        .btn-primary { background: var(--primary-color); color: white; border-color: var(--primary-color); box-shadow: 0 2px 4px rgba(14, 165, 233, 0.2); }
        .btn-primary:hover { background: #0284c7; transform: translateY(-1px); box-shadow: 0 4px 12px rgba(14, 165, 233, 0.3); }
        .btn-secondary { background: #f1f5f9; color: #475569; border-color: #e2e8f0; }
        .btn-secondary:hover { background: #e2e8f0; color: #1e293b; }
        .btn-outline { background: transparent; border-color: #e2e8f0; color: #64748b; }
        .btn-outline:hover { background: #f8fafc; color: var(--primary-color); border-color: var(--primary-color); }

        /* Modal Enhancements */
        .md-modal { background: #fff; border-radius: 16px; width: 100%; max-width: 800px; max-height: 90vh; overflow: hidden; display: flex; flex-direction: column; box-shadow: 0 25px 50px -12px rgba(0,0,0,0.15); border: 1px solid rgba(255,255,255,0.1); }
        .modal-header { padding: 1.25rem 1.5rem; border-bottom: 1px solid #f1f5f9; display: flex; justify-content: space-between; align-items: center; background: #fafafa; }
        .modal-header h3 { margin: 0; font-size: 1.1rem; font-weight: 700; color: #1e293b; }
        .modal-body { padding: 1.5rem; overflow-y: auto; flex: 1; }
        .modal-footer { padding: 1rem 1.5rem; border-top: 1px solid #f1f5f9; display: flex; justify-content: flex-end; gap: 0.75rem; background: #fafafa; }
        .close-modal { background: none; border: none; font-size: 1.5rem; color: #94a3b8; cursor: pointer; transition: color 0.1s; display: flex; align-items: center; justify-content: center; width:32px; height:32px; border-radius:50%; }
        .close-modal:hover { color: #1e293b; background: #f1f5f9; }

        /* Tree View (Hierarchy) Tab Styles */
        .tree-node { margin-left: 1.25rem; border-left: 1px solid #e2e8f0; padding-left: 0.75rem; margin-top: 0.25rem; }
        .tree-node.open > .tree-children { display: block; }
        .tree-node .tree-header { display: flex; align-items: center; justify-content: space-between; padding: 4px 8px; border-radius: 6px; transition: background 0.2s; }
        .tree-node .tree-header:hover { background: #f8fafc; }
        .tree-node .tree-actions { display: flex; gap: 0.75rem; opacity: 0; transition: opacity 0.2s; }
        .tree-node .tree-header:hover .tree-actions { opacity: 1; }
        .tree-node .tree-actions span { cursor: pointer; font-size: 0.75rem; color: var(--primary-color); }
        .tree-node .tree-actions span.danger { color: #ef4444; }
        .tree-node .tree-children { display: none; }
        .tree-node.open > .tree-children { display: block; }

        /* Toast Notification */
        #md-save-toast {
            position: fixed; top: 1.5rem; right: 1.5rem; padding: 1rem 1.5rem; border-radius: 12px;
            background: linear-gradient(135deg,#10b981,#059669); color: white; font-weight: 600; 
            font-size: 0.95rem; z-index: 100000; display: flex; align-items: center; gap: 0.75rem;
            box-shadow: 0 10px 25px rgba(0,0,0,0.15); transform: translateY(-20px); opacity: 0; 
            visibility: hidden; transition: all 0.4s cubic-bezier(0.175, 0.885, 0.32, 1.1);
        }
        #md-save-toast.show { transform: translateY(0); opacity: 1; visibility: visible; }
        #md-save-toast.error { background: linear-gradient(135deg,#f43f5e,#e11d48); }
        #md-save-toast.info { background: linear-gradient(135deg,#6366f1,#4f46e5); }
    </style>

    <div class="editor-container">
        <div id="md-save-toast">
            <svg xmlns="http://www.w3.org/2000/svg" width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2.5" stroke-linecap="round" stroke-linejoin="round"><path d="M20 6L9 17l-5-5"/></svg>
            <span id="md-save-toast-msg"></span>
        </div>
        
        <!-- Upload State -->
        <div id="uploadPrompt" class="upload-prompt">
            <div style="text-align: center; margin-bottom: 2.5rem;">
                <h2 style="font-size: 2rem; font-weight: 800; margin-bottom: 0.5rem; color: var(--text-primary);">Markdown Editor</h2>
                <p style="color: var(--text-secondary); font-size: 0.95rem;">Select how you want to open your project</p>
            </div>

            <div style="display: flex; gap: 1.5rem; justify-content: center; flex-wrap: wrap;">
                <!-- Open Folder Card -->
                <div class="upload-card" id="openFolderCard">
                    <div class="upload-icon-wrap" style="background: rgba(14,165,233,0.1);">
                        <svg xmlns="http://www.w3.org/2000/svg" width="40" height="40" viewBox="0 0 24 24" fill="none" stroke="#0ea5e9" stroke-width="1.5" stroke-linecap="round" stroke-linejoin="round"><path d="M22 19a2 2 0 0 1-2 2H4a2 2 0 0 1-2-2V5a2 2 0 0 1 2-2h5l2 3h9a2 2 0 0 1 2 2z"/></svg>
                    </div>
                    <h3>Open Folder</h3>
                    <p>Import a folder containing multiple Markdown files.</p>
                    <div class="upload-card-btn" style="background: #0ea5e9; color: #fff; border-color: #0ea5e9;">
                        <svg xmlns="http://www.w3.org/2000/svg" width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><path d="M22 19a2 2 0 0 1-2 2H4a2 2 0 0 1-2-2V5a2 2 0 0 1 2-2h5l2 3h9a2 2 0 0 1 2 2z"/></svg>
                        Choose Folder
                    </div>
                    <!-- NOTE: No hidden input here. window.selectFolder() handles this via showDirectoryPicker -->
                </div>
                <!-- Hidden fallback input (outside card so it does NOT intercept clicks) -->
                <input 
                    type="file" 
                    id="folderInput" 
                    multiple
                    webkitdirectory=""
                    style="display:none;"
                />

                <!-- Open File Card -->
                <div class="upload-card" onclick="document.getElementById(''fileInput'').click()">
                    <div class="upload-icon-wrap" style="background: rgba(16,185,129,0.1);">
                        <svg xmlns="http://www.w3.org/2000/svg" width="40" height="40" viewBox="0 0 24 24" fill="none" stroke="#10b981" stroke-width="1.5" stroke-linecap="round" stroke-linejoin="round"><path d="M14 2H6a2 2 0 0 0-2 2v16a2 2 0 0 0 2 2h12a2 2 0 0 0 2-2V8z"/><polyline points="14 2 14 8 20 8"/><line x1="16" y1="13" x2="8" y2="13"/><line x1="16" y1="17" x2="8" y2="17"/><polyline points="10 9 9 9 8 9"/></svg>
                    </div>
                    <h3>Open File</h3>
                    <p>Import individual Markdown files to edit.</p>
                    <div class="upload-card-btn" style="background: #fff; color: var(--text-primary); border-color: var(--border-color);">
                        <svg xmlns="http://www.w3.org/2000/svg" width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="#10b981" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><path d="M14 2H6a2 2 0 0 0-2 2v16a2 2 0 0 0 2 2h12a2 2 0 0 0 2-2V8z"/><polyline points="14 2 14 8 20 8"/></svg>
                        Choose File
                    </div>
                    <input 
                        type="file" 
                        id="fileInput"
                        accept=".md,.markdown" 
                        multiple
                        style="position: absolute; top:0; left:0; width:100%; height:100%; opacity:0; cursor: pointer;"
                    />
                </div>
            </div>
        </div>

        <!-- Main Interface (Hidden initially) -->
        <div id="mainEditorArea" style="display: none;">
            <!-- Sidebar -->
            <aside class="tree-sidebar">
                <div class="tree-header">
                    <span style="display:flex;align-items:center;gap:6px;font-weight:700;font-size:0.88rem;color:#1e293b;">
                        <svg xmlns="http://www.w3.org/2000/svg" width="14" height="14" viewBox="0 0 24 24" fill="none" stroke="#6366f1" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><circle cx="12" cy="12" r="3"/><path d="M19.07 4.93a10 10 0 0 1 0 14.14"/><path d="M4.93 4.93a10 10 0 0 0 0 14.14"/></svg>
                        Explorer
                    </span>
                </div>
                <div style="padding: 12px; display: flex; flex-direction: column; gap: 8px; border-bottom: 1px solid var(--border-color); background: #fafafa;">
                    <button id="btnSidebarChange" class="sidebar-btn" style="display:flex;align-items:center;justify-content:center;gap:8px;width:100%;padding:8px 12px;border:none;border-radius:6px;background:linear-gradient(135deg,#0ea5e9,#0284c7);color:#fff;font-size:0.85rem;font-weight:600;cursor:pointer;box-shadow:0 2px 4px rgba(14,165,233,0.25);transition:transform 0.2s;">
                        <svg xmlns="http://www.w3.org/2000/svg" width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2.5" stroke-linecap="round" stroke-linejoin="round"><path d="M3 7v10a2 2 0 0 0 2 2h14a2 2 0 0 0 2-2V9a2 2 0 0 0-2-2h-6l-2-2H5a2 2 0 0 0-2 2z"/></svg>
                        Change Folder
                    </button>
                    <button id="btnSidebarDownload" class="sidebar-btn" style="display:flex;align-items:center;justify-content:center;gap:8px;width:100%;padding:8px 12px;border:none;border-radius:6px;background:linear-gradient(135deg,#10b981,#059669);color:#fff;font-size:0.85rem;font-weight:600;cursor:pointer;box-shadow:0 2px 4px rgba(16,185,129,0.25);transition:transform 0.2s;">
                        <svg xmlns="http://www.w3.org/2000/svg" width="16" height="16" viewBox="0 0 24 24" stroke-width="2.5" stroke="currentColor" fill="none" stroke-linecap="round" stroke-linejoin="round"><path stroke="none" d="M0 0h24v24H0z" fill="none"/><path d="M4 17v2a2 2 0 0 0 2 2h12a2 2 0 0 0 2 -2v-2" /><path d="M7 11l5 5l5 -5" /><path d="M12 4l0 12" /></svg>
                        Download Project
                    </button>
                    <button id="btnSidebarClose" class="sidebar-btn" style="display:flex;align-items:center;justify-content:center;gap:8px;width:100%;padding:8px 12px;border:none;border-radius:6px;background:linear-gradient(135deg,#f43f5e,#e11d48);color:#fff;font-size:0.85rem;font-weight:600;cursor:pointer;box-shadow:0 2px 4px rgba(244,63,94,0.25);transition:transform 0.2s;">
                        <svg xmlns="http://www.w3.org/2000/svg" width="16" height="16" viewBox="0 0 24 24" stroke-width="2.5" stroke="currentColor" fill="none" stroke-linecap="round" stroke-linejoin="round"><path stroke="none" d="M0 0h24v24H0z" fill="none"/><path d="M18 6l-12 12" /><path d="M6 6l12 12" /></svg>
                        Close Project
                    </button>
                </div>
                <div id="folderTree" class="tree-content">
                    <!-- Tree Generated via JS -->
                </div>
            </aside>

            <!-- Main Content -->
            <main class="editor-main">



                    
                <div class="editor-header">
                    <h1 style="font-size:1.1rem;margin:0;font-weight:700;letter-spacing:-0.01em;display:flex;align-items:center;">
                        <i class="fas fa-file-invoice" style="margin-right:0.6rem;color:var(--primary-color);"></i>
                        <span id="editorFileTitle">Markdown Editor</span>
                    </h1>
                    <div style="display:flex;align-items:center;gap:1.25rem;">
                        <span id="totalTestCases" class="badge">0 Cases</span>
                        <button id="btnSaveFileAction" class="btn btn-primary" style="background:linear-gradient(135deg,var(--primary-color),#4f46e5); padding: 0.5rem 1.25rem;">
                            <i class="fas fa-save"></i> Save Changes
                        </button>
                    </div>
                </div>
                <!-- Top Tabs -->
                <!-- Top Tabs -->
                <div class="tabs" style="display:flex;gap:1.5rem;padding:0;background:#fff;align-items:center;flex-wrap:wrap; margin-top: 10px; border-radius:12px 12px 0 0; border: none; border-bottom: 2px solid #e2e8f0; padding-left: 20px;">
                    <button class="tab-btn active" data-tab="preview"  style="padding:1rem 0rem!important;border:none!important;cursor:pointer;font-size:0.82rem!important;font-weight:700!important;background:transparent!important;color:#0ea5e9!important; box-shadow: none; border-bottom: 2.5px solid #0ea5e9!important; border-radius:0!important;margin-bottom:-2px; text-transform: uppercase; letter-spacing: 0.05em;"><i class="fas fa-eye" style="margin-right:6px;"></i>Preview</button>
                    <button class="tab-btn"        data-tab="treeView" style="padding:1rem 0rem!important;border:none!important;cursor:pointer;font-size:0.82rem!important;font-weight:700!important;background:transparent!important;color:#64748b!important; box-shadow: none; border-radius:0!important;margin-bottom:-2px;border-bottom: 2.5px solid transparent!important; text-transform: uppercase; letter-spacing: 0.05em;"><i class="fas fa-sitemap" style="margin-right:6px;"></i>Hierarchy</button>
                    <button class="tab-btn"        data-tab="markdown" style="padding:1rem 0rem!important;border:none!important;cursor:pointer;font-size:0.82rem!important;font-weight:700!important;background:transparent!important;color:#64748b!important; box-shadow: none; border-radius:0!important;margin-bottom:-2px;border-bottom: 2.5px solid transparent!important; text-transform: uppercase; letter-spacing: 0.05em;"><i class="fas fa-code" style="margin-right:6px;"></i>Markdown</button>
                    <button class="tab-btn"        data-tab="json"     style="padding:1rem 0rem!important;border:none!important;cursor:pointer;font-size:0.82rem!important;font-weight:700!important;background:transparent!important;color:#64748b!important; box-shadow: none; border-radius:0!important;margin-bottom:-2px;border-bottom: 2.5px solid transparent!important; text-transform: uppercase; letter-spacing: 0.05em;"><i class="fas fa-brackets-curly" style="margin-right:6px;"></i>JSON</button>
                </div>

                <!-- Stretched Bulk Toolbar (Full-Width Optimization) -->
                <div class="qfg-bulk-toolbar" style="padding: 10px 20px;">
                  
                  <!-- Row 1: Selection | Divider | Actions | Divider | Properties | Spacer | Apply -->
                  <div class="qfg-bulk-row" style="border-bottom: 1px solid #f1f5f9; padding-bottom: 10px;">
                    <!-- Left: Selection -->
                    <div class="qfg-bulk-group">
                        <label class="qfg-select-all-label" style="display:flex;align-items:center;gap:8px;">
                          <input type="checkbox" id="selectAllTcs" style="width:16px;height:16px;">
                          <span style="font-weight:700">SELECT ALL</span>
                        </label>
                        <span id="selectedCountText" class="badge" style="background:#e0f2fe; color:#0369a1; border:1px solid #bae6fd;">0 selected</span>
                    </div>

                    <div class="qfg-bulk-divider"></div>

                    <!-- Center-Left: Quick Edit -->
                    <div class="qfg-bulk-group">
                        <button id="bulkEditBtn" class="btn btn-sm btn-primary" style="padding: 5px 14px; font-weight:700;">
                            <i class="fas fa-edit"></i> Edit
                        </button>
                        <button id="bulkDeleteBtn" class="btn btn-sm" style="padding: 5px 14px; background:#fff1f2; color:#be123c; border:1px solid #fecaca; font-weight:700;">
                            <i class="fas fa-trash-can"></i> Delete
                        </button>
                    </div>

                    <div class="qfg-bulk-divider"></div>

                    <!-- Center: Properties (Scenario/Exec) -->
                    <div class="qfg-bulk-group" style="gap:12px;">
                        <span class="qfg-bulk-label">Scenario</span>
                        <select id="bulkScenarioType" class="qfg-bulk-select" style="min-width: 15vw;">
                          <option value="">-- Scenario Type --</option>
                        </select>
                        <span class="qfg-bulk-label">Exec</span>
                        <select id="bulkExecutionType" class="qfg-bulk-select" style="min-width: 12vw;">
                          <option value="">-- Exec Type --</option>
                        </select>
                        <input type="text" id="bulkTags" class="qfg-bulk-input" placeholder="+ Tag" style="width: 110px;" />
                        <button id="applyBulkProps" class="btn btn-sm btn-primary" style="padding: 4px 12px; font-weight:700;">Set</button>
                    </div>

                    <div class="qfg-bulk-spacer"></div>

                    <!-- Right: Assign/Prio Apply -->
                    <div class="qfg-bulk-group">
                        <select id="bulkAssignSelect" class="qfg-bulk-select" style="min-width: 140px;">
                          <option value="">-- Assignee --</option>
                        </select>
                        <select id="bulkPrioritySelect" class="qfg-bulk-select" style="min-width: 90px;">
                          <option value="">-- Prio --</option>
                          <option value="Critical">Critical</option>
                          <option value="High">High</option>
                          <option value="Medium">Medium</option>
                          <option value="Low">Low</option>
                        </select>
                        <button id="applyBulkActions" class="btn btn-sm btn-primary" style="padding: 4px 16px; font-weight:800; background:linear-gradient(135deg,#2563eb,#0ea5e9);">APPLY</button>
                    </div>
                  </div>

                  <!-- Row 2: Add Run | Spacer | Reset -->
                  <div class="qfg-bulk-row" style="padding-top: 6px;">
                    <!-- Left: Run Config -->
                    <div class="qfg-bulk-group" style="gap:15px;">
                        <div style="display:flex;align-items:center;gap:10px;">
                            <span class="qfg-bulk-label" style="color:#0ea5e9">Add Run</span>
                            <input type="text" id="bulkCycleName" value="1.0" class="qfg-bulk-input" style="width:60px; text-align:center; font-weight:700;" />
                        </div>
                        <div style="display:flex;align-items:center;gap:6px;position:relative;">
                            <input type="text" id="bulkCycleDateText" class="qfg-bulk-input qf-date" placeholder="MM-DD-YYYY" style="width: 140px; cursor:pointer;" />
                            <input type="hidden" id="bulkCycleDate" />
                            <i class="fas fa-calendar-alt" style="position:absolute; right:8px; pointer-events:none; color:#94a3b8; font-size:0.85rem;"></i>
                        </div>
                        <div class="qfg-bulk-divider" style="height:16px;"></div>
                        <select id="bulkCycleAssignee" class="qfg-bulk-select" style="min-width: 180px;">
                          <option value="">-- Select Assignee --</option>
                        </select>
                        <select id="bulkCycleStatus" class="qfg-bulk-select" style="min-width: 150px;">
                          <option value="">-- Choose Status --</option>
                        </select>
                        <button id="applyBulkCycle" class="btn btn-sm btn-primary" style="background: #0ea5e9; border:none; padding: 4px 18px; font-weight:700;">
                          <i class="fas fa-plus"></i> ADD RUN ENTRY
                        </button>
                    </div>

                    <div class="qfg-bulk-spacer"></div>

                    <!-- Right: Tools -->
                    <div class="qfg-bulk-group">
                        <button id="resetBulkActions" class="btn btn-sm" style="background:#f8fafc; border:1px solid #e2e8f0; color:#94a3b8; padding: 6px 12px;" title="Reset All Fields">
                          <i class="fas fa-rotate-left"></i> Reset
                        </button>
                    </div>
                  </div>
                </div>



                <div id="editorContentScroll" class="editor-content-scroll" style="position: relative;">

                    <!-- Results.js targets this -->
                    <div class="tab-content active" id="preview" style="display: block;">

                        <div id="testCasesPreview" style="padding: 1.5rem;">
                            <!-- Top empty state header -->
                            <div style="margin-bottom: 2rem; padding-bottom: 1rem; border-bottom: 1px solid #e2e8f0; margin-top:-2rem;">
                                <h1 style="color: #0ea5e9; font-size: 1.1rem; font-weight: 700; margin: 0;">Select a file to edit</h1>
                            </div>
                            <!-- Centered icon empty state -->
                            <div style="text-align: center; color: var(--text-muted); padding-top: 5rem;">
                                <i class="fas fa-file-invoice" style="font-size: 3rem; opacity: 0.3; margin-bottom: 1rem;"></i>
                                <p style="font-size: 0.9rem; color:#94a3b8;">Select a Markdown file from the sidebar to view and edit schemas.</p>
                            </div>
                        </div>
                    </div>
                    
                    <div class="tab-content" id="treeView" style="display: none; padding: 1.5rem;">
                        <div id="treeViewContent"></div>
                    </div>
                    
                    <div class="tab-content" id="markdown" style="display: none; padding: 1.5rem;">
                        <textarea id="markdownContent" style="width: 100%; height: 600px; background: var(--bg-card); color: var(--text-primary); border: 1px solid var(--border-color); padding: 1rem; font-family: monospace;"></textarea>
                    </div>
                    
                    <div class="tab-content" id="json" style="display: none; padding: 1.5rem;">
                        <pre id="jsonContent" style="background: var(--bg-card); color: var(--text-primary); padding: 1rem; overflow: auto; max-height: 600px; border-radius: 8px;"></pre>
                    </div>
                </div>
                </div>


                </div>

                </div>

        </div>
    </div>

    <!-- Modals (Copied from Results page for editing functionality) -->
    
    <!-- Edit TC Modal -->
    <div id="editModal" class="modal-overlay">
        <div class="md-modal">
            <div class="modal-header">
                <h3>Edit Test Case</h3>
                <button class="close-modal" id="closeModal">&times;</button>
            </div>
            <div class="modal-body">
                <div class="form-row" style="display: grid; grid-template-columns: 1fr 1fr; gap: 1rem; margin-bottom: 1rem;">
                    <div class="form-group">
                        <label>ID (@id)</label>
                        <input type="text" id="editTcId" class="form-input" placeholder="e.g. TC-001" />
                    </div>
                    <div class="form-group">
                        <label>Requirement ID</label>
                        <input type="text" id="editTcReqId" class="form-input" placeholder="e.g. REQ-123" />
                    </div>
                </div>
                <div class="form-group">
                    <label>Title</label>
                    <input type="text" id="editTcTitle" class="form-input" />
                </div>
                <div class="form-group">
                    <label>Steps</label>
                    <textarea id="editTcSteps" class="form-input" rows="5"></textarea>
                </div>
                <div class="form-group">
                    <label>Expected Result</label>
                    <textarea id="editTcExpected" class="form-input" rows="3"></textarea>
                </div>
                <div class="form-row" style="display: grid; grid-template-columns: 1fr 1fr; gap: 1rem; margin-bottom: 1rem;">
                    <div class="form-group">
                        <label>Scenario Type</label>
                        <div style="display: flex; gap: 0.5rem;">
                            <input type="text" id="editTcScenarioType" class="form-input" placeholder="e.g. Happy Path" style="flex: 1; min-width: 120px;" />
                            <select id="editTcScenarioTypeSelect" class="form-input" style="width: auto;">
                                <option value="">Select</option>
                                <option value="Happy Path">Happy Path</option>
                                <option value="Negative">Negative</option>
                                <option value="Boundary">Boundary</option>
                                <option value="Security">Security</option>
                                <option value="Performance">Performance</option>
                            </select>
                        </div>
                    </div>
                    <div class="form-group">
                        <label>Execution Type</label>
                        <div style="display: flex; gap: 0.5rem;">
                            <input type="text" id="editTcExecutionType" class="form-input" placeholder="e.g. Manual" style="flex: 1; min-width: 120px;" />
                            <select id="editTcExecutionTypeSelect" class="form-input" style="width: auto;">
                                <option value="">Select</option>
                                <option value="Manual">Manual</option>
                                <option value="Automated">Automated</option>
                            </select>
                        </div>
                    </div>
                </div>
                <div class="form-group">
                    <label>Tags</label>
                    <div style="display: flex; gap: 0.5rem;">
                        <input type="text" id="editTcTags" class="form-input" style="flex: 1; min-width: 120px;" />
                        <select id="editTcTagsSelect" class="form-input" style="width: auto;">
                            <option value="">+ Add</option>
                        </select>
                    </div>
                </div>
                <div class="evidence-section" style="border-top: 1px solid var(--border-color); padding-top: 1rem;">
                     <div style="display:flex; justify-content:space-between; align-items:center; margin-bottom:10px;">
                         <h4 style="margin:0;">Evidence History</h4>
                         <button type="button" id="addEvidenceRowBtn" style="background:#eff6ff; color:#1e40af; border:1px solid #bfdbfe; border-radius:999px; padding:4px 12px; font-size:0.75rem; font-weight:600; cursor:pointer;">+ Add Evidence</button>
                     </div>
                     <div id="evidenceListContainer"></div>
                </div>
            </div>
            <div class="modal-footer">
                <button class="btn btn-secondary" id="cancelEdit">Cancel</button>
                <button class="btn btn-primary" id="saveEdit">Save</button>
            </div>
        </div>
    </div>
    
    <!-- Bulk Edit Modal -->
    <div id="bulkEditModal" class="modal-overlay">
        <div class="md-modal">
            <div class="modal-header">
                <h3>Bulk Edit Selected Cases</h3>
                <button class="close-modal" id="closeBulkEdit">&times;</button>
            </div>
            <div class="modal-body">
                <p style="margin-bottom: 1rem; color: var(--text-muted); font-size: 0.9rem;">Changes will be applied to all selected test cases. Leave fields empty to keep existing values.</p>
                
                <div class="form-row" style="display: grid; grid-template-columns: 1fr 1fr; gap: 1rem; margin-bottom: 1rem;">
                    <div class="form-group">
                        <label>Assignee</label>
                        <select id="bulkEditAssignee" class="form-input">
                            <option value="">-- No Change --</option>
                        </select>
                    </div>
                    <div class="form-group">
                        <label>Priority</label>
                        <select id="bulkEditPriority" class="form-input">
                            <option value="">-- No Change --</option>
                            <option value="Critical">Critical</option>
                            <option value="High">High</option>
                            <option value="Medium">Medium</option>
                            <option value="Low">Low</option>
                        </select>
                    </div>
                </div>

                <div class="form-row" style="display: grid; grid-template-columns: 1fr 1fr; gap: 1rem; margin-bottom: 1rem;">
                    <div class="form-group">
                        <label>Scenario Type</label>
                        <div style="display: flex; gap: 0.5rem;">
                            <input type="text" id="bulkEditScenarioType" class="form-input" placeholder="No Change" style="flex: 1; min-width: 120px;" />
                            <select id="bulkEditScenarioTypeSelect" class="form-input" style="width: auto;">
                                <option value="">Select</option>
                                <option value="Happy Path">Happy Path</option>
                                <option value="Negative">Negative</option>
                                <option value="Boundary">Boundary</option>
                                <option value="Security">Security</option>
                                <option value="Performance">Performance</option>
                            </select>
                        </div>
                    </div>
                    <div class="form-group">
                        <label>Execution Type</label>
                        <div style="display: flex; gap: 0.5rem;">
                            <input type="text" id="bulkEditExecutionType" class="form-input" placeholder="No Change" style="flex: 1; min-width: 120px;" />
                            <select id="bulkEditExecutionTypeSelect" class="form-input" style="width: auto;">
                                <option value="">Select</option>
                                <option value="Manual">Manual</option>
                                <option value="Automated">Automated</option>
                            </select>
                        </div>
                    </div>
                </div>

                <div class="form-group">
                    <label>Add Tags (comma separated)</label>
                    <div style="display: flex; gap: 0.5rem;">
                        <input type="text" id="bulkEditTags" class="form-input" placeholder="e.g. Functional, Login" style="flex: 1;" />
                        <select id="bulkEditTagsSelect" class="form-input" style="width: auto;">
                            <option value="">+ Add Tag</option>
                        </select>
                    </div>
                    <p style="font-size: 0.75rem; color: var(--text-muted); margin-top: 0.25rem;">New tags will be appended to existing ones.</p>
                </div>
            </div>
            <div class="modal-footer">
                <button class="btn btn-secondary" id="cancelBulkEdit">Cancel</button>
                <button class="btn btn-primary" id="saveBulkEdit">Apply Changes</button>
            </div>
        </div>
    </div>
    <div id="planEditModal" class="modal-overlay">
        <div class="md-modal">
            <div class="modal-header">
                <h3>Edit Plan</h3>
                <button class="close-modal" id="closePlanEdit">&times;</button>
            </div>
            <div class="modal-body">
                <div class="form-row" style="display: grid; grid-template-columns: 1fr 1fr; gap: 1rem; margin-bottom: 1rem;">
                    <div class="form-group">
                        <label>Plan Name</label>
                        <input type="text" id="editPlanName" class="form-input" />
                    </div>
                    <div class="form-group">
                        <label>Plan ID</label>
                        <input type="text" id="editPlanId" class="form-input" />
                    </div>
                </div>
                <div class="form-row" style="display: grid; grid-template-columns: 1fr 1fr; gap: 1rem; margin-bottom: 1rem;">
                    <div class="form-group">
                        <label>Plan Date</label>
                        <div style="display: flex; align-items: center; position: relative;">
                            <input type="text" id="editPlanDate" class="form-input qf-date" placeholder="MM-DD-YYYY" style="width: 100%; cursor: pointer;" />
                            <input type="hidden" id="editPlanDateIso" />
                            <i class="fas fa-calendar-alt" style="position: absolute; right: 10px; pointer-events: none; color: #94a3b8; font-size: 0.9rem;"></i>
                        </div>
                    </div>
                    <div class="form-group">
                        <label>Created By</label>
                        <select id="editPlanCreatedBy" class="form-input"></select>
                    </div>
                </div>
                <div class="form-group">
                    <label>Description</label>
                    <textarea id="editPlanDescription" class="form-input" rows="4"></textarea>
                </div>
                <div class="form-group">
                    <label>Metadata (YAML)</label>
                    <textarea id="editPlanYaml" class="form-input" rows="4"></textarea>
                </div>
            </div>
            <div class="modal-footer">
                <button class="btn btn-secondary" id="cancelPlanEdit">Cancel</button>
                <button class="btn btn-primary" id="savePlanEdit">Save</button>
            </div>
        </div>
    </div>

    <!-- Suite Edit Modal -->
    <div id="suiteEditModal" class="modal-overlay">
        <div class="md-modal">
            <div class="modal-header">
                <h3>Edit Suite</h3>
                <button class="close-modal" id="closeSuiteEdit">&times;</button>
            </div>
            <div class="modal-body">
                <div class="form-row" style="display: grid; grid-template-columns: 1fr 1fr; gap: 1rem; margin-bottom: 1rem;">
                    <div class="form-group">
                        <label>Suite Name</label>
                        <input type="text" id="editSuiteName" class="form-input" />
                    </div>
                    <div class="form-group">
                        <label>Suite ID</label>
                        <input type="text" id="editSuiteId" class="form-input" />
                    </div>
                </div>
                <div class="form-row" style="display: grid; grid-template-columns: 1fr 1fr; gap: 1rem; margin-bottom: 1rem;">
                    <div class="form-group">
                        <label>Suite Date</label>
                        <div style="display: flex; align-items: center; position: relative;">
                            <input type="text" id="editSuiteDate" class="form-input qf-date" placeholder="MM-DD-YYYY" style="width: 100%; cursor: pointer;" />
                            <input type="hidden" id="editSuiteDateIso" />
                            <i class="fas fa-calendar-alt" style="position: absolute; right: 10px; pointer-events: none; color: #94a3b8; font-size: 0.9rem;"></i>
                        </div>
                    </div>
                    <div class="form-group">
                        <label>Created By</label>
                        <select id="editSuiteCreatedBy" class="form-input"></select>
                    </div>
                </div>
                <div class="form-group">
                    <label>Description</label>
                    <textarea id="editSuiteDescription" class="form-input" rows="4"></textarea>
                </div>
                <div class="form-group">
                    <label>Metadata (YAML)</label>
                    <textarea id="editSuiteYaml" class="form-input" rows="4"></textarea>
                </div>
            </div>
            <div class="modal-footer">
                <button class="btn btn-secondary" id="cancelSuiteEdit">Cancel</button>
                <button class="btn btn-primary" id="saveSuiteEdit">Save</button>
            </div>
        </div>
    </div>


</div>
</div>
</div>
' AS html;

