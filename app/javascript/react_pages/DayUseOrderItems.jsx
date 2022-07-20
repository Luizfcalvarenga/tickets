import React, { useEffect, useState } from "react";
import moment from "moment-strftime";

export function DayUseOrderItems(props) {
  const [slotsInfosAndQuantities, setSlotsInfosAndQuantities] = useState(
    props.openSlots.map((slot) => {
      return {
        id: slot.id,
        start_time: slot.start_time,
        end_time: slot.end_time,
        passTypes: props.passTypes.map((passType) => {
          return {
            id: passType.id,
            quantity: 0,
            name: passType.name,
            price_in_cents: passType.price_in_cents,
          };
        }),
      };
    })
  );

  const [originalSlotsInfosAndQuantities, _] = useState(
    slotsInfosAndQuantities
  );

  const [couponCode, setCouponCode] = useState("");
  const [couponResult, setCouponResult] = useState(null);
  const [currentSlot, setCurrentSlot] = useState(slotsInfosAndQuantities[0]);

  const updateQuantity = (slotIndex, passTypeName, amount) => {
    const currentSlots = [...slotsInfosAndQuantities];

    const editedSlotItem = currentSlots[slotIndex];

    const editedPassType = editedSlotItem.passTypes.find((passType) => {
      return passType.name === passTypeName;
    });

    if (editedPassType.quantity === 0 && amount < 0) return;

    editedPassType.quantity = editedPassType.quantity + amount;

    setSlotsInfosAndQuantities(currentSlots);
  };

  const cartTotalInCents = () => {
    return slotsInfosAndQuantities
      .map((sl) => sl.passTypes)
      .flat()
      .reduce((memo, el) => {
        return (
          memo +
          el.price_in_cents * el.quantity * (1 + props.feePercentage / 100)
        );
      }, 0);
  };

  const applyCoupon = async (specificCoupon = "") => {
    try {
      const response = await axios.get(
        `/api/v1/coupons/${specificCoupon || couponCode}?entity_id=${
          props.dayUse.id
        }&entity_type=DayUse`
      );
      setCouponResult(response.data);

      if (response.data.success) {
        setSlotsInfosAndQuantities(
          props.openSlots.map((slot) => {
            return {
              id: slot.id,
              start_time: slot.start_time,
              end_time: slot.end_time,
              passTypes: props.passTypes.map((passType) => {
                const discountAmount =
                  response.data.coupon.kind == "percentage"
                    ? passType.price_in_cents *
                      (response.data.coupon.discount / 100)
                    : response.data.coupon.discount;
                let newPrice = passType.price_in_cents - discountAmount;
                if (newPrice <= 0) newPrice = 0;

                return {
                  id: passType.id,
                  quantity: slotsInfosAndQuantities
                    .find((s) => s.id === slot.id)
                    .passTypes.find((p) => p.id === passType.id).quantity,
                  name: passType.name,
                  price_in_cents: newPrice,
                };
              }),
            };
          })
        );
      } else {
        setSlotsInfosAndQuantities(originalSlotsInfosAndQuantities);
      }
    } catch {
      setCouponResult({
        result: false,
        message: "Erro ao buscar cupom",
      });

      setSlotsInfosAndQuantities(originalSlotsInfosAndQuantities);
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

  const startTime = () => {
    const date = new Date(props.date);
    var userTimezoneOffset = date.getTimezoneOffset() * 60000;
    const timeObject = new Date(date.getTime() + userTimezoneOffset);

    timeObject.setHours(
      new Date(props.dayUseSchedule.opens_at).getHours(),
      new Date(props.dayUseSchedule.opens_at).getMinutes()
    );

    return timeObject;
  };

  const feeInCents = (passType) => {
    return (
      (passType.price_in_cents / 100) * (parseFloat(props.feePercentage) / 100)
    );
  };

  const changeSlot = (amount) => {
    const currentSlotIndex = slotsInfosAndQuantities.findIndex(
      (slot) => slot === currentSlot
    );
    if (
      currentSlotIndex + amount < 0 ||
      currentSlotIndex + amount >= slotsInfosAndQuantities.length
    )
      return;
    setCurrentSlot(slotsInfosAndQuantities[currentSlotIndex + amount]);
  };

  return (
    <div className="event-batches-order">
      <div className="header bg-primary-color p-4">
        <p className="mb-0 fw-700 text-white">
          Ingressos para {moment(startTime()).strftime("%d/%m/%Y")}
        </p>
      </div>
      {props.openSlots.length > 1 && (
        <div className="border border-white p-4 flex center justify-content-center">
          <div
            className={`flex center between ${
              window.mobileMode() ? "w-100" : "w-30"
            }`}
          >
            <p className="m-0 fs-24 text-white">Horário:</p>
            <div className="flex center between gap-16">
              <i
                className={`fa fa-caret-left fs-60 ${
                  currentSlot !== slotsInfosAndQuantities[0]
                    ? "text-success clickable"
                    : "text-secondary"
                }`}
                onClick={() => changeSlot(-1)}
              ></i>
              <p className="m-0 text-center fs-24 text-white">
                {moment(currentSlot.start_time).strftime("%H:%M")} -{" "}
                {moment(currentSlot.end_time).strftime("%H:%M")}
              </p>
              <i
                className={`fa fa-caret-right fs-60 ${
                  currentSlot !==
                  slotsInfosAndQuantities[slotsInfosAndQuantities.length - 1]
                    ? "text-success clickable"
                    : "text-secondary"
                }`}
                onClick={() => changeSlot(1)}
              ></i>
            </div>
          </div>
        </div>
      )}

      <div className="body border-white border">
        {slotsInfosAndQuantities.map((slot, index) => {
          return (
            <div className={slot === currentSlot ? "" : "d-none"}>
              {slot.passTypes.map((passType) => {
                return (
                  <div className="border-bottom border-white p-4 flex center between">
                    <div className="f-60">
                      <p className="m-0 f-10 text-white">
                        {moment(slot.start_time).strftime("%H:%M")} -{" "}
                        {moment(slot.end_time).strftime("%H:%M")} -{" "}
                        {passType.name}
                      </p>
                      <p className="m-0 f-20 text-white">
                        {(passType.price_in_cents / 100).toLocaleString(
                          "pt-BR",
                          {
                            style: "currency",
                            currency: "BRL",
                          }
                        )}
                        {props.feePercentage > 0 && (
                          <>
                            {" "}
                            &nbsp;(+&nbsp;
                            {feeInCents(passType).toLocaleString("pt-BR", {
                              style: "currency",
                              currency: "BRL",
                            })}{" "}
                            taxa)
                          </>
                        )}
                      </p>
                    </div>

                    <div
                      className={`flex center around ${
                        window.mobileMode() ? "f-30" : "f-15"
                      }`}
                    >
                      <i
                        className="fa fa-minus-circle fs-30 text-white clickable"
                        onClick={() => updateQuantity(index, passType.name, -1)}
                      ></i>
                      <p className="m-0 text-white">{passType.quantity}</p>
                      <i
                        className="fa fa-plus-circle fs-30 text-white clickable"
                        onClick={() => updateQuantity(index, passType.name, 1)}
                      ></i>
                    </div>

                    <input
                      type="hidden"
                      name="order[order_items][][quantity]"
                      value={passType.quantity}
                    />
                    <input
                      type="hidden"
                      name="order[order_items][][day_use_schedule_pass_type_id]"
                      value={passType.id}
                    />
                    <input
                      type="hidden"
                      name="order[order_items][][start_time]"
                      value={slot.start_time}
                    />
                    <input
                      type="hidden"
                      name="order[order_items][][end_time]"
                      value={slot.end_time}
                    />
                  </div>
                );
              })}
              {slot.passTypes.length <= 0 && (
                <p className="p-5">Nenhum tipo de ingresso disponível.</p>
              )}
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
          <p
            className="btn btn-underline text-underline f-10 m-0 px-5"
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
