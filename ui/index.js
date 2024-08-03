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
            <img src="nui://ox_inventory/web/images/${item.name}.png" alt="${item.label}" class="item-image">
            <span class="item-name">${item.label}</span>
            <span class="item-price">${item.price}$</span>
            <button class="buy-button" data-item-name="${item.name}" data-item-price="${item.price}"><i class="fa-solid fa-cart-shopping"></i>Vásárlás</button>
            `;

      shopItemsContainer.appendChild(itemElement);
    });

    document.querySelectorAll(".buy-button").forEach((button) => {
      button.addEventListener("click", function () {
        const itemName = this.getAttribute("data-item-name");
        const itemPrice = this.getAttribute("data-item-price");
        fetch(`https://${GetParentResourceName()}/buyItem`, {
          method: "POST",
          headers: {
            "Content-Type": "application/json; charset=UTF-8",
          },
          body: JSON.stringify({
            itemName: itemName,
            itemPrice: itemPrice,
          }),
        })
          .then((resp) => resp.json())
          .then((resp) => {
            console.log(resp);
          })
          .catch((error) => {
            console.error("Error:", error);
          });
      });
    });
  } else if (event.data.type === "closeShop") {
    const shopContainer = document.getElementById("shop");
    shopContainer.classList.remove("show");
    setTimeout(() => {
      shopContainer.style.display = "none";
    }, 300);
  }
});

document.getElementById("close-button").addEventListener("click", function () {
  fetch(`https://${GetParentResourceName()}/closeShop`, {
    method: "POST",
  })
    .then((resp) => resp.json())
    .then((resp) => {
      console.log(resp);
    })
    .catch((error) => {
      console.error("Error:", error);
    });
});

window.addEventListener("keyup", (e) => {
  if (e.key == "Escape") {
    fetch(`https://${GetParentResourceName()}/closeShop`, {
      method: "POST",
    });
  }
});
