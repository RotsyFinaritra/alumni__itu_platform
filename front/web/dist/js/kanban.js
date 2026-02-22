// ne change pas le signature de la fonction
function scrollKanban(button, direction) {
    const container = button.parentElement.querySelector('.kanban-container');
    const scrollAmount = 400;
    container.scrollBy({ left: direction * scrollAmount, behavior: 'smooth' });
}

// ne change pas le signature de la fonction
function showScrollButtons(wrapper) {
    wrapper.querySelectorAll('.scroll-btn').forEach(btn => btn.style.display = 'block');
}

// ne change pas le signature de la fonction
function hideScrollButtons(wrapper) {
    wrapper.querySelectorAll('.scroll-btn').forEach(btn => btn.style.display = 'none');
}

// ne change pas le signature de la fonction
function toggleMenu(button) {
    const wrapper = button.parentElement;
    const menu = wrapper.querySelector('.export-menu');

    // Fermer les autres menus ouverts
    document.querySelectorAll('.export-menu').forEach(m => {
        if (m !== menu) m.style.display = 'none';
    });

    // Toggle current
    menu.style.display = (menu.style.display === 'none' || menu.style.display === '') ? 'block' : 'none';
}

// Fermer le menu si on clique en dehors
document.addEventListener('click', function (e) {
    if (!e.target.closest('.menu-wrapper')) {
        document.querySelectorAll('.export-menu').forEach(m => m.style.display = 'none');
    }
});

// ne change pas le signature de la fonction
function exportSectionToPDF(sectionId) {
    const section = document.getElementById(sectionId);
    if (!section) {
        console.error("Section non trouvée :", sectionId);
        return;
    }

    const cards = Array.from(section.querySelectorAll('.kanban-card'));
    const generationDate = new Date().toLocaleString();

    const PAGE_HEIGHT_PX = 1122; // A4 à ~96dpi
    const PAGE_PADDING = 40;
    const REMAINING_HEIGHT_INIT = PAGE_HEIGHT_PX - PAGE_PADDING * 2 - 100; // en-tête estimé

    const exportContainer = document.createElement('div');
    exportContainer.setAttribute("style", "font-family: 'Helvetica', sans-serif; width: 800px; margin: auto;");

    let pageNumber = 1;
    let currentPage = createPage(pageNumber);
    exportContainer.appendChild(currentPage);
    let remainingHeight = REMAINING_HEIGHT_INIT;

    for (let i = 0; i < cards.length; i++) {
        const card = cards[i];
        const cardClone = cloneCard(card);

        // Mesure la hauteur réelle du clone
        document.body.appendChild(cardClone);
        const cardHeight = cardClone.offsetHeight;
        document.body.removeChild(cardClone);

        if (cardHeight > remainingHeight) {
            pageNumber++;
            currentPage = createPage(pageNumber);
            exportContainer.appendChild(currentPage);
            remainingHeight = REMAINING_HEIGHT_INIT;
        }

        currentPage.appendChild(cardClone);
        remainingHeight -= cardHeight + 20;
    }

    html2pdf().set({
        margin: 0.5,
        filename: "section_" + sectionId + ".pdf",
        image: { type: 'jpeg', quality: 0.98 },
        html2canvas: { scale: 2, useCORS: true },
        jsPDF: { unit: 'in', format: 'a4', orientation: 'portrait' }
    }).from(exportContainer).save();

    function cloneCard(card) {
        const clone = card.cloneNode(true);
        clone.setAttribute("style",
            "width: 550px; "
        );
        return clone;
    }

    function createPage(pageNumber) {
        const page = document.createElement('div');
        page.setAttribute("style", "page-break-after: always; width: 800px; box-sizing: border-box; padding: 20px; position: relative;");

        // En-tête stylisé
        const header = document.createElement('div');
        header.setAttribute("style", "border-bottom: 1px solid #ccc; padding-bottom: 10px; margin-bottom: 20px;");
        header.innerHTML = `
        <div style="display: flex; justify-content: space-between; align-items: center;">
            <div>
                <h2 style="margin: 0; font-size: 20px; color: #333;">Section ID : ${sectionId}</h2>
                <p style="margin: 4px 0; font-size: 13px; color: #666;">G&eacute;n&eacute;r&eacute; le : ${generationDate}</p>
                <div style="font-size: 13px; color: #2e2c2c;">Page ${pageNumber}</div>
            </div>
        </div>`;

        page.appendChild(header);

        return page;
    }
}



function toggleSection(sectionId) {
    const section = document.getElementById(sectionId);
    if (!section) return;

    const btn = section.querySelector('.toggle-section-btn');

    if (section.classList.contains('collapsed')) {
        section.classList.remove('collapsed');
        btn.innerHTML = "&#9660;"; // flèche vers le bas
    } else {
        section.classList.add('collapsed');
        btn.innerHTML = "&#9654;"; // flèche vers la droite
    }
}

function dupliquerCard(cardId) {
    const kanbanContainer = document.getElementById('kanban-container');
    const table = kanbanContainer?.dataset.table;
    const classe = kanbanContainer?.dataset.mapping;

    const payload = { cardId, table, classe };
    console.log(payload);

    fetch(`/teamTask/kanban/duplique`, {
        method: "POST",
        headers: { "Content-Type": "application/json" },
        body: JSON.stringify(payload)
    })
        .then(res => res.json())
        .then(data => {
            if (!data.success) {
                console.error("Erreur update kanban", data);
                alert(data.message);
                return;
            }

            const originalCard = document.querySelector(`.kanban-card[data-id='${cardId}']`);
            if (!originalCard) return;

            // Cloner la carte
            const clonedCard = originalCard.cloneNode(true);

            // Mettre le nouveau data-id
            clonedCard.dataset.id = data.message;

            // Optionnel : mettre un petit highlight ou animation pour signaler la duplication
            clonedCard.style.transition = "all 0.3s ease";
            clonedCard.style.transform = "scale(1.05)";
            setTimeout(() => {
                clonedCard.style.transform = "";
            }, 200);

            // Ajouter juste après la carte originale
            originalCard.insertAdjacentElement('afterend', clonedCard);

            const duplicateBtn = clonedCard.querySelector('.duplicate-btn');
            if (duplicateBtn) {
                duplicateBtn.onclick = () => dupliquerCard(data.message);
            }
        })
        .catch(err => {
            console.error("Erreur réseau", err);
        });
}

function attachFormListener() {
    const form = document.getElementById("date-filter-form");
    if (!form) return;

    form.addEventListener("submit", function(event) {
        event.preventDefault();

        const dateDebut = document.getElementById("dateDebut").value;
        const dateFin = document.getElementById("dateFin").value;

        const params = new URLSearchParams({
            dateDebut: dateDebut,
            dateFin: dateFin
        });

        // Recharge avec filtres
        loadKanbanContent(params.toString());
    });
}


function initKanbanDrag() {

    document.querySelectorAll('.kanban-data-container').forEach(container => {
        if (container.dataset.sortableInit) return;
        container.dataset.sortableInit = "true";
        let oldGroupId = null;
        let oldIndex = null;
        let oldContainer = null;


        const SCROLL_ZONE = 120;      // zone sensible (px)
        const SCROLL_SPEED = 15;    // vitesse de scroll

        let kanbanScrollInterval = null;

        function startAutoScroll(container, direction) {
            stopAutoScroll();
            kanbanScrollInterval = setInterval(() => {
                container.scrollLeft += direction * SCROLL_SPEED;
            }, 16); // ~60fps
        }

        function stopAutoScroll() {
            if (kanbanScrollInterval) {
                clearInterval(kanbanScrollInterval);
                kanbanScrollInterval = null;
            }
        }

        function rollbackCard(evt) {
            if (!oldContainer || oldIndex === null) return;

            const items = oldContainer.children;

            if (oldIndex >= items.length) {
                oldContainer.appendChild(evt.item);
            } else {
                oldContainer.insertBefore(evt.item, items[oldIndex]);
            }
        }


        new Sortable(container, {
            group: 'kanban-shared',
            animation: 180,
            ghostClass: 'kanban-ghost',
            chosenClass: 'kanban-chosen',
            dragClass: 'kanban-drag',
            filter: '.duplicate-btn',


            onStart(evt) {
                evt.item.classList.add('kanban-moving');

                oldContainer = evt.from;          // colonne d'origine
                oldIndex = evt.oldIndex;          // position d'origine

                const section = evt.from.closest('.kanban-section');
                oldGroupId = section?.dataset.id || null;
            },

            onMove(evt) {
                const kanban = document.getElementById('kanban-container');
                if (!kanban) return;

                const rect = kanban.getBoundingClientRect();
                const x = evt.originalEvent.clientX;

                // gauche
                if (x < rect.left + SCROLL_ZONE) {
                    startAutoScroll(kanban, -1);
                }
                // droite
                else if (x > rect.right - SCROLL_ZONE) {
                    startAutoScroll(kanban, 1);
                }
                else {
                    stopAutoScroll();
                }
            },

            onEnd(evt) {
                stopAutoScroll();
                evt.item.classList.remove('kanban-moving');

                const cardId = evt.item.dataset.id;

                const newSection = evt.to.closest('.kanban-section');
                const newGroupId = newSection?.dataset.id || null;
                const newGroupLabel = newSection?.querySelector('.title')?.innerText.trim();

                const table = document.getElementById('kanban-container')?.dataset.table;
                const classe = document.getElementById('kanban-container')?.dataset.classe;
                const colonne = document.getElementById('kanban-container')?.dataset.colonne;

                const countOldGroup = document.getElementById("count_" + oldGroupId);
                const countNewGroup = document.getElementById("count_" + newGroupId);

                if (!oldGroupId || oldGroupId === newGroupId) {
                    oldGroupId = null;
                    return;
                }

                const oldCountVal = countOldGroup ? parseInt(countOldGroup.innerText) : null;
                const newCountVal = countNewGroup ? parseInt(countNewGroup.innerText) : null;

                if (countOldGroup) countOldGroup.innerText = oldCountVal - 1;
                if (countNewGroup) countNewGroup.innerText = newCountVal !== null ? newCountVal + 1 : 1;

                const payload = {
                    cardId,
                    oldGroupId,
                    newGroupId,
                    newGroupLabel,
                    table,
                    classe,
                    colonne
                };


                fetch(`/teamTask/kanban/update`, {
                    method: "POST",
                    headers: {
                        "Content-Type": "application/json"
                    },
                    body: JSON.stringify(payload)
                })
                    .then(res => res.json())
                    .then(data => {
                        if (!data.success) {
                            console.error("Erreur update kanban", data);
                            rollbackCard(evt);

                            if (countOldGroup) countOldGroup.innerText = oldCountVal;
                            if (countNewGroup) countNewGroup.innerText = newCountVal;

                            Swal.fire({
                                title: "Ouupss !",
                                text: data.message,
                                icon: "error",
                                confirmButtonText: "OK"
                            });
                        }
                    })
                    .catch(err => {
                        console.error("Erreur réseau", err);
                        rollbackCard(evt);

                        if (countOldGroup) countOldGroup.innerText = oldCountVal;
                        if (countNewGroup) countNewGroup.innerText = newCountVal;

                        Swal.fire({
                            title: "Ouupss !",
                            text: "Erreur serveur",
                            icon: "error",
                            confirmButtonText: "OK"
                        });
                    });

                oldGroupId = null;
            }
        });
    });
}
