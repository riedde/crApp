/* Filter um Editionen auszublenden */
function filterEdition(siglum) {
    const isChecked = document.getElementById(siglum).checked;
    const spans = document.querySelectorAll(`span[siglum="${siglum}"]`);

    spans.forEach(span => {
        span.closest('.alert').style.display = isChecked ? 'block' : 'none';
    });
}