async function searchCandidates() {
    const puesto = document.getElementById("puesto").value;
    const descripcion = document.getElementById("descripcion").value;
    const nResultados = document.getElementById("nResultados").value;
    const searchResults = document.getElementById("searchResults");

    searchResults.innerHTML = `
        <div class="loading-spinner"></div>
        <p style="text-align:center;">Buscando candidatos...</p>
    `;

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
                div.classList.add("candidate-card");

                const shortText = candidato.texto.substring(0, 200);
                const fullText = candidato.texto;
                const showMoreBtn = `<button class="show-more-btn">Ver más</button>`;

                div.innerHTML = `
                    <h3>${candidato.nombre}</h3>
                    <p class="candidate-score">⭐ Score: ${candidato.score.toFixed(2)}</p>
                    <p class="candidate-text">${shortText}...</p>
                    ${fullText.length > 200 ? showMoreBtn : ""}
                `;

                searchResults.appendChild(div);

                if (fullText.length > 200) {
                    const btn = div.querySelector(".show-more-btn");
                    const textElement = div.querySelector(".candidate-text");

                    btn.addEventListener("click", () => {
                        if (btn.textContent === "Ver más") {
                            textElement.textContent = fullText;
                            btn.textContent = "Ver menos";
                        } else {
                            textElement.textContent = shortText + "...";
                            btn.textContent = "Ver más";
                        }
                    });
                }
            });
        } else {
            searchResults.innerHTML = "No se encontraron resultados.";
        }
    } catch (error) {
        searchResults.innerHTML = "Error en la búsqueda.";
        searchResults.style.color = "red";
    }
}