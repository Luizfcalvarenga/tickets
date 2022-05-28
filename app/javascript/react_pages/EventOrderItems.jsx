import React, { useEffect, useState } from "react";
const moment = require("moment-strftime");

export function EventOrderItems(props) {
  const [batchesInfosAndQuantities, setBatchesInfosAndQuantities] = useState(
    props.eventBatches.map((eventBatch) => {
      return {
        id: eventBatch.id,
        passType: eventBatch.pass_type,
        name: eventBatch.name,
        ends_at: eventBatch.ends_at,
        priceInCents: eventBatch.price_in_cents,
        feeInCents:
          eventBatch.price_in_cents * parseFloat(props.feePercentage / 100),
        totalInCents:
          eventBatch.price_in_cents *
          (1 + parseFloat(props.feePercentage / 100)),
        quantity: 0,
      };
    })
  );

  const [couponCode, setCouponCode] = useState("");
  const [couponResult, setCouponResult] = useState(null);

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
      (partialSum, batchInfosAndQuantities) => {
        const discountAmountPerPass = (couponResult && couponResult.success ? (couponResult.coupon.kind == "percentage" ? batchInfosAndQuantities.totalInCents * (couponResult.coupon.discount / 100) : couponResult.coupon.discount ) : 0)
        let pricePerPass = batchInfosAndQuantities.totalInCents - discountAmountPerPass
        if (pricePerPass < 0) pricePerPass = 0

        return partialSum +
          batchInfosAndQuantities.quantity *
            pricePerPass;
      },
      0
    );
  };

  const applyCoupon = async (specificCoupon = "") => {
    try {
      const response = await axios.get(
        `/api/v1/coupons/${specificCoupon || couponCode}?entity_id=${props.event.id}&entity_type=Event`
      );
      setCouponResult(response.data);
    } catch {
      setCouponResult({
        result: false,
        message: "Erro ao buscar cupom",
      });
    }
  };

  useEffect(() => {
    const queryString = window.location.search;
    const urlParams = new URLSearchParams(queryString);
    const couponCodeFromParams = urlParams.get("coupon_code");

    if (couponCodeFromParams) {
      setCouponCode(couponCodeFromParams);
      applyCoupon(couponCodeFromParams);
    }
  }, [])

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
                  {props.feePercentage > 0 && (
                    <>
                      &nbsp;(+&nbsp;
                      {(batch.feeInCents / 100).toLocaleString("pt-BR", {
                        style: "currency",
                        currency: "BRL",
                      })}&nbsp;
                      taxa)
                    </>
                  )}
                </p>
                <p className="m-0">
                  Vendas até {moment(batch.ends_at).strftime("%d/%m/%Y")}
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
        <div
          className={`border-bottom border-white p-4 flex center between gap-24 ${
            window.mobileMode() ? "flex-column" : ""
          }`}
        >
          <p className="f-20 m-0 text-white">Cupom de desconto</p>
          <input
            type="text"
            name="coupon_code"
            value={couponCode}
            class="f-20"
            onChange={(e) => setCouponCode(e.target.value)}
          />
          <p className="btn btn-success f-10 m-0 px-5" onClick={() => applyCoupon()}>
            Aplicar
          </p>
          <div className="f-40 text-center">
            {couponResult && (
              <div>
                {!couponResult.success ? (
                  <div className="flex center gap-24">
                    <i className="fa fa-times-circle f-24 text-danger"></i>
                    <p className="m-0 text-danger">{couponResult.message}</p>
                  </div>
                ) : (
                  <div className="flex center gap-24">
                    <i className="fa fa-check-circle f-24 text-success"></i>
                    <p className="m-0 text-success">{`Desconto de ${couponResult.discount_display} aplicado a cada passe`}</p>
                  </div>
                )}
              </div>
            )}
          </div>
        </div>
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
