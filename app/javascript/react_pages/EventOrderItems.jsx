import React, { useEffect, useState } from "react";

export function EventOrderItems(props) {
  const [batchesInfosAndQuantities, setBatchesInfosAndQuantities] = useState(
    props.eventBatches.map((eventBatch) => {
      return {
        id: eventBatch.id,
        passType: eventBatch.pass_type,
        name: eventBatch.name,
        priceInCents: eventBatch.price_in_cents,
        feeInCents: eventBatch.price_in_cents * parseFloat(props.feePercentage / 100),
        totalInCents: eventBatch.price_in_cents * (1 + parseFloat(props.feePercentage / 100)),
        quantity: 0,
      };
    })
  );

  const updateQuantity = (batchIndex, amount) => {
    const currentBatches = [...batchesInfosAndQuantities];

    const editedBatchItem = currentBatches[batchIndex];

    if (editedBatchItem.quantity === 0 && amount < 0) return;

    currentBatches[batchIndex].quantity =
      currentBatches[batchIndex].quantity + amount;

    setBatchesInfosAndQuantities(currentBatches);
  };

  const cartTotalInCents = () => {
    return batchesInfosAndQuantities.reduce(
      (partialSum, batchInfosAndQuantities) =>
        partialSum +
        batchInfosAndQuantities.quantity * batchInfosAndQuantities.totalInCents,
      0
    );
  };

  return (
    <div className="event-batches-order">
      <div className="header bg-primary-color p-4">
        <p className="mb-0 fw-700 text-white">Ingressos</p>
      </div>

      <div className="body border-white border">
        {batchesInfosAndQuantities.map((batch, index) => {
          return (
            <div
              key={index}
              className="border-bottom border-white p-4 flex center between"
            >
              <div className="f-60">
                <p className="m-0 f-60 text-white">
                  {batch.passType} - {batch.name}
                </p>
                <p className="m-0 f-20 text-white">
                  {(batch.priceInCents / 100).toLocaleString("pt-BR", {
                    style: "currency",
                    currency: "BRL",
                  })}
                  {props.feePercentage > 0 && 
                    <>
                      {" "}
                      &nbsp;(+&nbsp;
                      {(batch.feeInCents / 100).toLocaleString("pt-BR", {
                        style: "currency",
                        currency: "BRL",
                      })}{" "}
                      taxa)
                    </>
                  }
                </p>
              </div>

              <div
                className={`flex center around ${
                  window.mobileMode() ? "f-30" : "f-15"
                }`}
              >
                <i
                  className="fa fa-minus-circle fs-30 text-white clickable"
                  onClick={() => updateQuantity(index, -1)}
                ></i>
                <p className="m-0 text-white">{batch.quantity}</p>
                <i
                  className="fa fa-plus-circle fs-30 text-white clickable"
                  onClick={() => updateQuantity(index, 1)}
                ></i>
              </div>

              <input
                type="hidden"
                name="order[order_items][][event_batch_id]"
                value={batch.id}
              />
              <input
                type="hidden"
                name="order[order_items][][quantity]"
                value={batch.quantity}
              />
            </div>
          );
        })}
      </div>

      <p className="text-center text-white mt-5">
        <i className="fas fa-shopping-cart fs-30 mr-3"></i>
        <span className="px-3">
          {(cartTotalInCents() / 100).toLocaleString("pt-BR", {
            style: "currency",
            currency: "BRL",
          })}
        </span>
      </p>
    </div>
  );
}
