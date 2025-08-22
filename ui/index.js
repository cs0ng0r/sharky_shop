$(document).ready(function() {
  window.addEventListener("message", function (event) {
    if (event.data.type === "openShop") {
      const shopContainer = $("#shop");
      shopContainer.show();
      setTimeout(() => {
        shopContainer.addClass("show");
      }, 10);

      const shopItems = event.data.items;
      const shopItemsContainer = $("#shop-items");
      shopItemsContainer.empty();

      shopItems.forEach((item) => {
        const itemElement = $(`
          <div class="shop-item">
            <div class="item-header">
              <img src="nui://ox_inventory/web/images/${item.name}.png" alt="${item.label}" class="item-image">
              <div class="item-info">
                <div class="item-name">${item.label}</div>
                <div class="item-price" data-base-price="${item.price}">$${parseFloat(item.price).toFixed(2)}</div>
              </div>
            </div>
            <div class="item-controls">
              <div class="quantity-control">
                <button class="quantity-btn decrease" data-action="decrease">−</button>
                <input type="number" class="quantity-input" value="1" min="1" max="100">
                <button class="quantity-btn increase" data-action="increase">+</button>
              </div>
              <button class="buy-button" data-item-name="${item.name}">
                <i class="fas fa-shopping-cart"></i>
                <span>Vásárlás</span>
              </button>
            </div>
          </div>
        `);

        shopItemsContainer.append(itemElement);
      });

      setupEventListeners();
    } else if (event.data.type === "closeShop") {
      closeShop();
    }
  });

  function setupEventListeners() {
    $(".quantity-input").off().on("input", function () {
      validateAndUpdatePrice($(this));
    });
    
    $(".quantity-input").off("blur").on("blur", function () {
      if (!$(this).val() || $(this).val() < 1) {
        $(this).val(1);
        validateAndUpdatePrice($(this));
      }
    });

    $(".quantity-btn").off().on("click", function () {
      const action = $(this).data("action");
      const itemElement = $(this).closest(".shop-item");
      const quantityInput = itemElement.find(".quantity-input");
      let currentValue = parseInt(quantityInput.val()) || 1;

      if (action === "increase" && currentValue < 100) {
        quantityInput.val(currentValue + 1);
      } else if (action === "decrease" && currentValue > 1) {
        quantityInput.val(currentValue - 1);
      }

      validateAndUpdatePrice(quantityInput);
    });

    $(".buy-button").off().on("click", function () {
      const $button = $(this);
      if ($button.prop("disabled")) return;

      const itemName = $button.data("item-name");
      const itemElement = $button.closest(".shop-item");
      const quantityInput = itemElement.find(".quantity-input");
      const quantity = parseInt(quantityInput.val()) || 1;

      if (quantity > 0 && quantity <= 100) {
        $button.prop("disabled", true).css("opacity", "0.6");
        
        $.post(`https://${GetParentResourceName()}/buyItem`, JSON.stringify({
          itemName: itemName,
          itemQuantity: quantity,
        }))
        .done(function() {
          setTimeout(() => {
            $button.prop("disabled", false).css("opacity", "1");
          }, 1000);
        })
        .fail(function(error) {
          console.error("Error:", error);
          $button.prop("disabled", false).css("opacity", "1");
        });
      }
    });
  }

  function validateAndUpdatePrice($quantityInput) {
    const itemElement = $quantityInput.closest(".shop-item");
    const itemPriceElement = itemElement.find(".item-price");
    const basePrice = parseFloat(itemPriceElement.data("base-price"));
    let quantity = parseInt($quantityInput.val());

    if (isNaN(quantity) || quantity < 1) {
      quantity = 1;
      $quantityInput.val(1);
    } else if (quantity > 100) {
      quantity = 100;
      $quantityInput.val(100);
    }

    const totalPrice = basePrice * quantity;
    itemPriceElement.text(`$${totalPrice.toFixed(2)}`);
  }

  function closeShop() {
    const shopContainer = $("#shop");
    shopContainer.removeClass("show");
    setTimeout(() => {
      shopContainer.hide();
    }, 400);
  }

  $("#close-button").on("click", function () {
    $.post(`https://${GetParentResourceName()}/closeShop`)
      .fail(function(error) {
        console.error("Error:", error);
      });
  });

  $(window).on("keyup", function(e) {
    if (e.key === "Escape") {
      $.post(`https://${GetParentResourceName()}/closeShop`);
    }
  });
});
