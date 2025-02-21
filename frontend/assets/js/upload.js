async function uploadCV() {
    const fileInput = document.getElementById("cvFile");
    const applicantName = document.getElementById("applicantName").value;
    const uploadMessage = document.getElementById("uploadMessage");
    
    if (!fileInput.files.length || !applicantName) {
        uploadMessage.textContent = "Por favor, ingrese su nombre y seleccione un archivo.";
        uploadMessage.style.color = "red";
        return;
    }
    
    const file = fileInput.files[0];
    const reader = new FileReader();
    
    reader.onload = async function () {
        const base64String = reader.result.split(",")[1];
        const payload = {
            applicant_name: applicantName,
            body: base64String
        };
        
        try {
            const response = await fetch("https://lvycei3la1.execute-api.us-east-1.amazonaws.com/dev/upload", {
                method: "POST",
                headers: { "Content-Type": "application/json" },
                body: JSON.stringify(payload)
            });
            
            const result = await response.json();
            uploadMessage.textContent = "Archivo subido correctamente.";
            uploadMessage.style.color = "green";
        } catch (error) {
            uploadMessage.textContent = "Error al subir el archivo.";
            uploadMessage.style.color = "red";
        }
    };
    
    reader.readAsDataURL(file);
}
