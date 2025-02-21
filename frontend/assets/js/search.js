async function searchCandidates() {
    const puesto = document.getElementById("puesto").value;
    const descripcion = document.getElementById("descripcion").value;
    const nResultados = document.getElementById("nResultados").value;
    const searchResults = document.getElementById("searchResults");

    searchResults.innerHTML = "Buscando...";

    if (!puesto || !descripcion) {
        searchResults.innerHTML = "Por favor, complete todos los campos.";
        searchResults.style.color = "red";
        return;
    }

    const payload = {
        puesto,
        descripcion_puesto: descripcion,
        n_resultados: parseInt(nResultados, 10)
    };

    try {
        const response = await fetch("https://lvycei3la1.execute-api.us-east-1.amazonaws.com/dev/search", {
            method: "POST",
            headers: { "Content-Type": "application/json" },
            body: JSON.stringify(payload)
        });

        const result = await response.json();
        
        if (result.resultados && result.resultados.length > 0) {
            searchResults.innerHTML = "";
            result.resultados.forEach(candidato => {
                const div = document.createElement("div");
                div.innerHTML = `<strong>${candidato.nombre}</strong>: ${candidato.texto.substring(0, 100)}...`;
                div.style.padding = "8px";
                div.style.borderBottom = "1px solid #ccc";
                searchResults.appendChild(div);
            });
        } else {
            searchResults.innerHTML = "No se encontraron resultados.";
        }
    } catch (error) {
        searchResults.innerHTML = "Error en la búsqueda.";
        searchResults.style.color = "red";
    }
}
