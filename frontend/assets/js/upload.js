async function uploadCV() {
    const fileInput = document.getElementById("cvFile");
    const applicantName = document.getElementById("applicantName").value;
    const uploadMessage = document.getElementById("uploadMessage");
    const uploadButton = document.getElementById("uploadButton"); // 🔹 Verifica que este ID existe

    if (!fileInput.files.length || !applicantName) {
        uploadMessage.innerHTML = "⚠️ Por favor, ingrese su nombre y seleccione un archivo.";
        uploadMessage.style.color = "red";
        return;
    }

    const file = fileInput.files[0];
    const reader = new FileReader();

    uploadMessage.innerHTML = `<div class="loading-spinner"></div> <p style="text-align:center;">Subiendo archivo...</p>`;
    
    // ✅ Solo deshabilita el botón si existe en el DOM
    if (uploadButton) uploadButton.disabled = true;

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
            uploadMessage.innerHTML = "✅ Archivo subido correctamente.";
            uploadMessage.style.color = "green";
        } catch (error) {
            uploadMessage.innerHTML = "❌ Error al subir el archivo.";
            uploadMessage.style.color = "red";
        } finally {
            // ✅ Solo habilita el botón si existe en el DOM
            if (uploadButton) uploadButton.disabled = false;
        }
    };

    reader.readAsDataURL(file);
}