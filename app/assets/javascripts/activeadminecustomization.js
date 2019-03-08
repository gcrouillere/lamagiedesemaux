$(document).ready(function() {
  $('.display-one-month').on('click', function() {
    if ($('.display-one-month').hasClass('clicked')) {
      $('.inner-CA').css({'display': 'none'});
      $('.display-one-month').removeClass('clicked');
    } else {
      $('.inner-CA').css({'display': 'block'});
      $('.display-one-month').addClass('clicked');
    }
  });
});

function OnloadFunction() {
  // PRODUCT POSITION UPDATE BY DRAG N DROP
 document.querySelectorAll('#index_table_produits tbody tr').forEach(
    x => {
      x.setAttribute('draggable', 'true');
    }
  );

  var productRows = Array.from(document.querySelectorAll('#index_table_produits tbody tr'));

  [].forEach.call(productRows, function(product_row) {
    product_row.addEventListener('dragstart', onDragStart, false);
    product_row.addEventListener('dragover', onDragOver, false);
    product_row.addEventListener('drop', onDrop, false);
    product_row.addEventListener('drop', onDragEnd, false);
  });

  // PRODUCT FIELD UPDATE ON BLUR
   var editableCells = Array.from(document.querySelectorAll("td.col.col-name, td.col.col-description, td.col.col-stock, td.col.col-weight,td.col.col-price_cents, td.col.col-category"));

  [].forEach.call(editableCells, function(editableCell){
    editableCell.addEventListener('click', clickOnEditableCell, false);
  });
}

$(document).ready(OnloadFunction);

var draggedProduct = null;
var draggedIndex = null;
var initialIDSorder = null
var productRows = null
var rowsFinalPositions = null

onDragOver = (event) => {
  if (event.preventDefault) {
    event.preventDefault();
  }
}

onDrop = (event) => {
  if(event.preventDefault) { event.preventDefault(); }
  if(event.stopPropagation) { event.stopPropagation(); }

  if (checkPositionUpdateReference().bool) {
    window.alert(`Vous ne pouvez pas ordonner les produits par rapport au ${checkPositionUpdateReference().paramName}. Veuillez cliquer sur l'en tête de colonne "Position" 2 fois, de manière à afficher les produits dans l'ordre croissant.`)
    return;
  }

  if (draggedProduct != event.srcElement.parentElement) {

    // Get data on target position and element
    let initialPositions = Array.from(document.querySelectorAll('#index_table_produits tbody tr td.col-position')).map(x => x.innerHTML);
    let targetElement = event.srcElement.parentElement;
    let targetIndex = initialIDSorder.indexOf(targetElement.querySelector('td.col-id').innerHTML);

    // Insert product in target position
    productRows.splice(draggedIndex, 1);
    productRows.splice(targetIndex, 0, draggedProduct);

    // Get ordered rows html content
    let finalHTMLs = productRows.map(x => x.innerHTML);

    // Modify DOM with html content
    Array.from(document.querySelectorAll('#index_table_produits tbody tr')).forEach((x, index) => {
     x.innerHTML = finalHTMLs[index]
    });
    document.querySelectorAll('#index_table_produits tbody tr td.col-position').forEach((x, index) => {
     x.innerHTML = index + parseInt(initialPositions[0])
    });
    updatePositionsInDB(initialPositions[0]);
  }
}

onDragStart = (event) => {
  initialIDSorder = Array.from(document.querySelectorAll('#index_table_produits tbody tr td.col-id')).map(x => x.innerHTML);
  productRows = Array.from(document.querySelectorAll('#index_table_produits tbody tr'));
  draggedProduct = event.srcElement;
  draggedIndex = initialIDSorder.indexOf(draggedProduct.querySelector('td.col-id').innerHTML);
  document.querySelectorAll('#index_table_produits tbody tr').forEach(x => x.classList.remove("drag-end-animation"));
  event.dataTransfer.setData('text', draggedProduct);
}


updatePositionsInDB = (startingPosition) => {
  rowsFinalPositions = Array.from(document.querySelectorAll('#index_table_produits tbody tr td.col-id')).map(x => x.innerHTML);
  var urlRoot = window.location.origin;
  $.ajax({
    type: "GET",
    url: `${urlRoot}/ceramiques/update_positions_after_swap_in_admin?finalPositions=[${rowsFinalPositions}]&startingPosition=${startingPosition}`,
    dataType: "JSON"
  }).done((data) => {
    console.log("done");
    OnloadFunction();
  }).fail((data) => {
    console.log("fail")
  })
}

onDragEnd = (event) => {
  event.currentTarget.classList.add("drag-end-animation");
  clearAnimations("fail-update");
  clearAnimations("sucess-update");
}

function checkPositionUpdateReference() {
  if (window.location.search.length > 10) {
    let lastSearchParamNameAndValue = (window.location.search.split("&").filter(x => !(x.match(/locale|page/)))[0] || "=").split("=")[1]
    let lastSearchParamName = lastSearchParamNameAndValue.substr(0, lastSearchParamNameAndValue.indexOf("_"))
    return {bool: !(lastSearchParamNameAndValue === "position_asc"), paramName: lastSearchParamName}
  } else {
    return {bool: false, paramName: ""}
  }
}

// PRODUCT FIELD UPDATE ON BLUR

clickOnEditableCell = (event) => {
  cell = event.target
  cell.parentElement.setAttribute('draggable', 'false');
  clearAnimations("fail-update");
  clearAnimations("sucess-update");
  clearAnimations("drag-end-animation");
  var urlRoot = window.location.origin;

  if (Array.from(cell.classList).indexOf("editing") == -1 && cell.nodeName == "TD") {

    // Get data to build input
    initialValue = cell.innerText
    fullDescriptionOfCorrespondingRow = cell.parentElement.querySelector('.hidden-desc').innerHTML
    trimedDescription = fullDescriptionOfCorrespondingRow.substr(fullDescriptionOfCorrespondingRow.match(/\S/).index, fullDescriptionOfCorrespondingRow.length)
    updatingField = cell.classList[1].split("-")[1];
    productID = cell.parentElement.querySelector('.col-id').innerText
    value = updatingField.match(/description/) ? trimedDescription.replace(/"/g, '&quot;') : cell.innerText.replace(/"/g, '&quot;');

    //Build input
    cell.classList.add("editing");
    cell.innerHTML = inputConstruction(updatingField, value)
    input = document.querySelector(".editingInput")
    input.focus();

    // Submit on blur
    input.addEventListener('blur', function(event) {

      inputType = input.getAttribute('type')
      relatedCell = this.parentElement;
      relatedRow = this.parentElement.parentElement;
      relatedCell.classList.remove('editing');
      newValue = updatingField == 'category' ? this.options[this.selectedIndex].value : this.value;
      newCategoryValue = updatingField == 'category' ? this.options[this.selectedIndex].innerHTML : ""

      //VALIDATION
      if (validateField(newValue, inputType)) {
        //DOM UPDATE
        if (updatingField == 'category') {
          relatedCell.innerHTML = newCategoryValue
        } else {
          relatedCell.innerHTML = newValue.length > 200 ? `${newValue.substr(0, 200)} ...` : newValue;
        }
        relatedRow.setAttribute('draggable', 'true')

        // UPDATE DB
        $.ajax({
          type: "PATCH",
          url: `${urlRoot}/bijoux/${productID}`,
          dataType: "JSON",
          data: {ceramique: {[updatingField]: newValue}}
        }).done((data) => {
          console.log("done");
          relatedCell.classList.add("sucess-update");
          if (updatingField == "description") relatedRow.querySelector(".hidden-desc").innerHTML = newValue
          OnloadFunction();
        }).fail((data) => {
          relatedCell.classList.add("fail-update")
          relatedCell.innerHTML = data.responseJSON.fieldvalue;
        })
      } else {
        // HIGHLIGHT ERROR
        relatedCell.classList.add("fail-update")
        relatedCell.innerHTML = initialValue
      }
    })
  }
}

validateField = (fieldValue, inputType) => {
  return fieldValue !== "" && (inputType == "number" ? (fieldValue >= 0 && Number.isInteger(parseInt(fieldValue))) : true)
}

inputConstruction = (updatingField, value) => {
  if (updatingField != 'category') {
    htmlTag = updatingField.match(/description/) ? "textarea" : "input";
    type = updatingField.match(/name|description/) ? "text" : "number";
    htmlTagClosure = updatingField.match(/description/) ? `${value}</textarea>` : "";
    return `<${htmlTag} type=${type} name="${updatingField}" value="${value}" class="editingInput ${updatingField}"/>${htmlTagClosure}`
  } else {
    categories = document.querySelector(".hidden-categories").innerHTML.split('#').map(x => x.split("£"))
    return `<select class="editingInput ${updatingField}">${
      categories.map(categorie =>  `<option value=${categorie[1]}>${categorie[0]}</option>`).join("")
      }</select>`
  }
}

clearAnimations = (givenClass) => {
  document.querySelectorAll(`.${givenClass}`).forEach(x => x.classList.remove(givenClass))
}
