window.addEventListener("message", function (event) {
  if (event.data.type === "openShop") {
    const shopContainer = document.getElementById("shop");
    shopContainer.style.display = "block";
    setTimeout(() => {
      shopContainer.classList.add("show");
    }, 10);

    const shopItems = event.data.items;
    const shopItemsContainer = document.getElementById("shop-items");
    shopItemsContainer.innerHTML = "";

    shopItems.forEach((item) => {
      const itemElement = document.createElement("div");
      itemElement.className = "shop-item";

      itemElement.innerHTML = `
        <img src="nui://ox_inventory/web/images/${item.name}.png" alt="${
        item.label
      }" class="item-image">
        <span class="item-name">${item.label}</span>
        <span class="item-price" data-base-price="${item.price}">${parseFloat(
        item.price
      ).toFixed(2)}$</span>
        <div class="quantity-control">
          <input type="number" class="quantity-input" value="1" min="1">
          <button class="buy-button" data-item-name="${
            item.name
          }" data-item-price="${item.price}">
            <i class="fas fa-shopping-cart"></i> Vásárlás
          </button>
        </div>
      `;

      shopItemsContainer.appendChild(itemElement);
    });

    setupEventListeners();
  } else if (event.data.type === "closeShop") {
    const shopContainer = document.getElementById("shop");
    shopContainer.classList.remove("show");
    setTimeout(() => {
      shopContainer.style.display = "none";
    }, 300);
  }
});

function setupEventListeners() {
  document.querySelectorAll(".quantity-input").forEach((input) => {
    input.addEventListener("input", function () {
      updatePrice(this);
    });
  });

  document.querySelectorAll(".buy-button").forEach((button) => {
    button.addEventListener("click", function () {
      const itemName = this.getAttribute("data-item-name");
      const basePrice = parseFloat(this.getAttribute("data-item-price"));

      // Find the quantity input within the same shop-item
      const itemElement = this.closest(".shop-item");
      const quantityInput = itemElement.querySelector(".quantity-input");
      const quantity = quantityInput.value;

      // Send item details to Lua
      fetch(`https://${GetParentResourceName()}/buyItem`, {
        method: "POST",
        headers: {
          "Content-Type": "application/json; charset=UTF-8",
        },
        body: JSON.stringify({
          itemName: itemName,
          itemPrice: basePrice,
          itemQuantity: quantity,
        }),
      })
        .then((resp) => resp.json())
        .catch((error) => console.error("Error:", error));
    });
  });
}

function updatePrice(quantityInput) {
  const itemElement = quantityInput.closest(".shop-item");
  const itemPriceElement = itemElement.querySelector(".item-price");
  const basePrice = parseFloat(itemPriceElement.dataset.basePrice);
  const quantity = parseInt(quantityInput.value);

  if (!isNaN(quantity) && quantity > 0) {
    const totalPrice = basePrice * quantity;
    itemPriceElement.textContent = `${totalPrice.toFixed(2)}$`;
  }
}

document.getElementById("close-button").addEventListener("click", function () {
  fetch(`https://${GetParentResourceName()}/closeShop`, { method: "POST" })
    .then((resp) => resp.json())
    .catch((error) => console.error("Error:", error));
});

window.addEventListener("keyup", (e) => {
  if (e.key === "Escape") {
    fetch(`https://${GetParentResourceName()}/closeShop`, { method: "POST" });
  }
});
