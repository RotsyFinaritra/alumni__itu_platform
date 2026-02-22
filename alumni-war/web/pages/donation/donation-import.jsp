<%
    String lien = request.getContextPath();
%>

<div class="content-wrapper">
    <h1 class="mb-3">
        Importation de Donations
    </h1>
    <div class="container">


        <!-- Main Card -->
        <div class="row justify-content-center">
            <div>
                <div class="main-card">
                    <div class="card-body p-5">
                        <form action="<%=lien%>/importExcelNew"
                              method="post" 
                              class="import-form"
                              enctype="multipart/form-data"
                              id="importForm">
                            <div class="row">
                                <div>
                                    <!-- Drag & Drop Zone -->
                                    <div class="mb-4">
                                        <div id="dropZone" class="drop-zone text-center">
                                            
                                            <!-- Corner Dashes -->
                                            <div class="corner-dash corner-top-left"></div>
                                            <div class="corner-dash corner-top-right"></div>
                                            <div class="corner-dash corner-bottom-left"></div>
                                            <div class="corner-dash corner-bottom-right"></div>
                                            
                                            <div class="mb-4">
                                                <i class="fas fa-cloud-upload-alt upload-icon"></i>
                                            </div>
                                            
                                            <h4 class="mb-3 drop-zone-title">
                                                Glissez et d&eacute;posez votre fichier ici
                                            </h4>
                                            <p class="text-muted mb-4 drop-zone-subtitle">
                                                ou cliquez pour s&eacute;lectionner un fichier
                                            </p>
                                            
                                            <div class="file-format-badge">
                                                <i class="fas fa-file-excel excel-icon"></i>
                                                <span class="format-text">Fichiers Excel uniquement (.xls, .xlsx)</span>
                                            </div>
                                            
                                            <input type="file" 
                                                   name="file" 
                                                   id="fileInput" 
                                                   accept=".xls,.xlsx"
                                                   class="d-none"
                                                   required>
                                        </div>

                                        <!-- File Info Display -->
                                        <div id="fileInfo" class="file-info mt-4 d-none">
                                            <div class="file-info-inner">
                                                <div class="file-info-content">
                                                    
                                                    <div class="file-details">
                                                        <p class="mb-1 file-label">
                                                            Fichier s&eacute;lectionn&eacute;
                                                        </p>
                                                        <p class="mb-0 file-name-text" id="fileName"></p>
                                                    </div>
                                                </div>
                                            </div>
                                        </div>

                                        <!-- Action Buttons -->

                                        <div class="box-footer nopadding borderless action-buttons">
                                             <button type="submit" 
                                                    id="submitBtn"
                                                   class="pull-right btn btn-primary"
                                                   style="margin-left: 10px;"
                                                   >
                                                Importer le fichier
                                            </button>
                                            <button type="reset" 
                                                    class="pull-right btn btn-tertiary">
                                                R&eacute;initialiser
                                            </button>
                                           
                                        </div>
                                    </div>
                                </div>
                            </div>

                        </form>
                    </div>
                </div>

                <!-- Help Text -->
                <div class="text-center mt-4">
                    <p class="help-text">
                        <i class="fas fa-shield-alt me-2"></i>
                        Vos donn&eacute;es sont s&eacute;curis&eacute;es et prot&eacute;g&eacute;es
                    </p>
                </div>
            </div>
        </div>
    </div>
</div>

<style>
    /* Page Styles */
    .page-subtitle {
        font-size: 1.1rem;
        color: rgba(255,255,255,0.9);
        font-weight: 300;
    }

    /* Main Card */
    .main-card {
        border-radius: 24px;
        box-shadow: 0 20px 60px rgb(139 139 139 / 30%);
        overflow: hidden;
        border: none;
        background: white;
    }

    /* Form */
    .import-form {
        margin: 3em;
    }

    /* Drop Zone */
    .drop-zone {
        border: 3px dashed #cbd5e0;
        background: linear-gradient(145deg, #f8fafc 0%, #f1f5f9 100%);
        cursor: pointer;
        border-radius: 20px;
        min-height: 280px;
        display: flex;
        flex-direction: column;
        justify-content: center;
        align-items: center;
        position: relative;
        padding: 40px;
        transition: all 0.3s ease;
    }

    #dropZone.drag-over {
        background: linear-gradient(145deg, #eef2ff 0%, #e0e7ff 100%);
        border-color: #667eea;
        box-shadow: 0 0 0 4px rgba(102, 126, 234, 0.1);
        transform: scale(1.02);
    }

    /* Corner Dashes */
    .corner-dash {
        position: absolute;
        width: 40px;
        height: 40px;
    }

    .corner-top-left {
        top: 20px;
        left: 20px;
        border-top: 4px solid #667eea;
        border-left: 4px solid #667eea;
        border-radius: 8px 0 0 0;
    }

    .corner-top-right {
        top: 20px;
        right: 20px;
        border-top: 4px solid #667eea;
        border-right: 4px solid #667eea;
        border-radius: 0 8px 0 0;
    }

    .corner-bottom-left {
        bottom: 20px;
        left: 20px;
        border-bottom: 4px solid #667eea;
        border-left: 4px solid #667eea;
        border-radius: 0 0 0 8px;
    }

    .corner-bottom-right {
        bottom: 20px;
        right: 20px;
        border-bottom: 4px solid #667eea;
        border-right: 4px solid #667eea;
        border-radius: 0 0 8px 0;
    }

    /* Icons */
    .upload-icon {
        font-size: 4rem;
        color: #667eea;
    }

    .excel-icon {
        color: #667eea;
    }

    /* Drop Zone Text */
    .drop-zone-title {
        color: #1e293b;
        font-weight: 700;
    }

    .drop-zone-subtitle {
        font-size: 1rem;
    }

    /* File Format Badge */
    .file-format-badge {
        display: flex;
        gap: 8px;
        align-items: center;
        background: white;
        padding: 12px 24px;
        border-radius: 50px;
        box-shadow: 0 4px 12px rgba(0,0,0,0.08);
    }

    .format-text {
        color: #64748b;
        font-size: 0.9rem;
        font-weight: 500;
    }

    /* File Info */
    .file-info {
        
    }

    .file-info-inner {
        padding: 1rem;
        border-radius: 0.5rem;
        background: linear-gradient(135deg, #e0f2fe 0%, #dbeafe 100%);
        border-left: 5px solid #0ea5e9;
        margin-top: 1em;
    }

    .file-info-content {
        display: flex;
        align-items: center;
        gap: 1rem;
        margin-top: 15px;
        margin-bottom: 15px;
    }

    .file-details {
        margin: 27px;
    }

    .file-label {
        font-weight: 700;
        color: #0c4a6e;
        font-size: 1rem;
    }

    .file-name-text {
        color: #0369a1;
        font-size: 0.95rem;
    }

    /* Action Buttons */
    .action-buttons {
        margin-top: 30px;
        background: transparent;
    }

    /* Help Text */
    .help-text {
        color: rgba(255,255,255,0.8);
        font-size: 0.95rem;
    }

    .btn-lg {
        font-size: 1rem;
    }

    @media (max-width: 768px) {
        h1 {
            font-size: 2rem !important;
        }

        #dropZone {
            min-height: 240px;
            padding: 30px !important;
        }
        
        .d-flex.justify-content-end {
            flex-direction: column;
        }
        
        .btn-lg {
            width: 100%;
        }
    }
</style>

<script>
    document.addEventListener('DOMContentLoaded', function() {
        const dropZone = document.getElementById('dropZone');
        const fileInput = document.getElementById('fileInput');
        const fileInfo = document.getElementById('fileInfo');
        const fileName = document.getElementById('fileName');
        const importForm = document.getElementById('importForm');

        // Click to select file
        dropZone.addEventListener('click', function() {
            fileInput.click();
        });

        // Drag over
        dropZone.addEventListener('dragover', function(e) {
            e.preventDefault();
            dropZone.classList.add('drag-over');
        });

        dropZone.addEventListener('dragleave', function() {
            dropZone.classList.remove('drag-over');
        });

        // Drop file
        dropZone.addEventListener('drop', function(e) {
            e.preventDefault();
            dropZone.classList.remove('drag-over');
            
            const files = e.dataTransfer.files;
            if (files.length > 0) {
                handleFileSelect(files[0]);
            }
        });

        // File input change
        fileInput.addEventListener('change', function() {
            if (this.files.length > 0) {
                handleFileSelect(this.files[0]);
            }
        });

        // Handle file selection
        function handleFileSelect(file) {
            // Validate file type
            const validTypes = ['application/vnd.openxmlformats-officedocument.spreadsheetml.sheet', 
                              'application/vnd.ms-excel'];
            const validExtensions = ['.xls', '.xlsx'];
            
            const hasValidType = validTypes.includes(file.type);
            const hasValidExtension = validExtensions.some(ext => file.name.toLowerCase().endsWith(ext));
            
            if (!hasValidType && !hasValidExtension) {
                alert('Veuillez s&eacute;lectionner un fichier Excel valide (.xls ou .xlsx)');
                fileInput.value = '';
                return;
            }

            fileName.textContent = file.name + ' (' + formatFileSize(file.size) + ')';
            fileInfo.classList.remove('d-none');
        }

        // Format file size
        function formatFileSize(bytes) {
            if (bytes === 0) return '0 Bytes';
            const k = 1024;
            const sizes = ['Bytes', 'KB', 'MB'];
            const i = Math.floor(Math.log(bytes) / Math.log(k));
            return Math.round(bytes / Math.pow(k, i) * 100) / 100 + ' ' + sizes[i];
        }

        // Form reset
        importForm.addEventListener('reset', function(e) {
            // Hide file info
            fileInfo.classList.add('d-none');
            // Clear file name
            fileName.textContent = '';
            // Clear file input
            fileInput.value = '';
        });

        // Form submit
        importForm.addEventListener('submit', function(e) {
            if (fileInput.files.length === 0) {
                e.preventDefault();
                alert('Veuillez s&eacute;lectionner un fichier');
            }
        });
    });
</script>
