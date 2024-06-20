/* Filtern der Cards im Katalog nach Ampelsystem */
function filterEdition(siglum) {
    if(document.getElementById(siglum).checked) {
        const divs = document.getElementsByClassName('col-3');
        for (let x = 0; x < divs.length; x++) {
            const div = divs[x];
            const content = div.textContent.trim();
            const container = div.parentElement.parentElement;
        
            if (content.includes(siglum)) { container.style.display = 'block'; }
        }
    }
    else {
        const divs = document.getElementsByClassName('col-3');
        for (let x = 0; x < divs.length; x++) {
            const div = divs[x];
            const content = div.textContent.trim();
            const container = div.parentElement.parentElement;
        
            if (content.includes(siglum)) { container.style.display = 'none'; }
        }
    }
}
