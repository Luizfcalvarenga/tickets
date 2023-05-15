import React, { useEffect, useState } from "react";
const moment = require("moment-strftime");

export function EventOrderItems(props) {
  const [couponSection, setCouponSection] = useState(false)
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

  const [
    originalBatchesInfosAndQuantitIes,
    _,
  ] = useState(batchesInfosAndQuantities);

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

  const toggleCouponSection = (e) => {
    e.currentTarget.classList.toggle('btn-clicked')
    setCouponSection((prevCouponSection) => !prevCouponSection);
  };

  const cartTotalInCents = () => {
    return batchesInfosAndQuantities.reduce(
      (partialSum, batchInfosAndQuantities) => {
        return partialSum + batchInfosAndQuantities.quantity * batchInfosAndQuantities.totalInCents;
      },
      0
    );
  };

  const applyCoupon = async (specificCoupon = "") => {
    try {
      const response = await axios.get(
        `/api/v1/coupons/${specificCoupon || couponCode}?entity_id=${
          props.event.id
        }&entity_type=Event`
      );
      setCouponResult(response.data);

      if (response.data.success) {
        setBatchesInfosAndQuantities(
          props.eventBatches.map((eventBatch) => {
            const discountAmount =
              response.data.coupon.kind == "percentage"
                ? eventBatch.price_in_cents *
                  (response.data.coupon.discount / 100)
                : response.data.coupon.discount;
            let newPrice = eventBatch.price_in_cents - discountAmount;
            if (newPrice <= 0) newPrice = 0;
            return {
              id: eventBatch.id,
              passType: eventBatch.pass_type,
              name: eventBatch.name,
              ends_at: eventBatch.ends_at,
              priceInCents: newPrice,
              feeInCents: newPrice * parseFloat(props.feePercentage / 100),
              totalInCents:
                newPrice * (1 + parseFloat(props.feePercentage / 100)),
              quantity: batchesInfosAndQuantities.find(b => b.id === eventBatch.id).quantity,
            };
          })
        );
      } else {
        setBatchesInfosAndQuantities(originalBatchesInfosAndQuantitIes);
      }
    } catch {
      setCouponResult({
        result: false,
        message: "Erro ao buscar cupom",
      });
      setBatchesInfosAndQuantities(originalBatchesInfosAndQuantitIes);
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
  }, []);

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
                      })}
                      &nbsp; taxa)
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
        <button type="button" className="toggle-coupon-btn w-100 d-flex justify-content-around" onClick={(e) => toggleCouponSection(e)}>Inserir Cumpom <i id="section-arrow" className="fas fa-chevron-down"></i></button>
        {couponSection && (
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
              className="f-20"
              onChange={(e) => setCouponCode(e.target.value)}
            />
            <p
              className="btn btn-underline f-10 m-0 px-5"
              onClick={() => applyCoupon()}
            >
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
        )}
      </div>

      <div classname="border border-bottom-0 border border-top-0 border-white">
        <p className="text-center text-white mt-3">
          <i className="fas fa-shopping-cart fs-30 mr-3"></i>
          <span className="px-3">
            {(cartTotalInCents() / 100).toLocaleString("pt-BR", {
              style: "currency",
              currency: "BRL",
            })}
          </span>
        </p>
      </div>
    </div>
  );
}
