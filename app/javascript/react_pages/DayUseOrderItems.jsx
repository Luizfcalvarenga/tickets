import React, { useEffect, useState } from "react";
import moment from "moment-strftime";
import { TailSpin } from "react-loader-spinner";
import _ from "lodash";

export function DayUseOrderItems(props) {
  const [availablePassTypes, setAvailablePassTypes] = useState([]);
  const [originalSlotsInfosAndQuantities, setOriginalSlotsInfosAndQuantities] =
    useState();
  const [orderItems, setOrderItems] = useState([]);

  const [couponCode, setCouponCode] = useState("");
  const [couponResult, setCouponResult] = useState(null);
  const [currentDate, setCurrentDate] = useState();
  const [currentSlot, setCurrentSlot] = useState();
  const [recoverSlotTime, setRecoverSlotTime] = useState();
  const [waitingSubmit, setWaitingSubmit] = useState(false);
  const [waitingForPasses, setWaitingForPasses] = useState(true);
  const [dayUsePackages, setDayUsePackages] = useState([]);

  useEffect(() => {
    fetchAvailablePasses();
  }, []);

  const fetchAvailablePasses = async () => {
    const response = await axios(`/api/v1/day_uses/${props.dayUse.id}`);
    const sanitizedSlotsInfosAndQuantities = response.data.available_slots.map(
      (date) => {
        return {
          date: date.date,
          weekday_display: date.weekday_display,
          open_slots_for_date: date.open_slots_for_date.map((slot) => {
            return {
              start_time: slot.start_time,
              end_time: slot.end_time,
              passTypes: slot.available_pass_types.map((passType) => {
                return {
                  id: passType.id,
                  name: passType.name,
                  price_in_cents: passType.price_in_cents,
                  available_quantity: passType.available_quantity,
                  slot: slot,
                };
              }),
            };
          }),
        };
      }
    );
    setCurrentDate(sanitizedSlotsInfosAndQuantities[0]);
    setCurrentSlot(sanitizedSlotsInfosAndQuantities[0].open_slots_for_date[0]);
    setAvailablePassTypes(sanitizedSlotsInfosAndQuantities);
    setOriginalSlotsInfosAndQuantities(sanitizedSlotsInfosAndQuantities);

    setDayUsePackages(response.data.day_use_packages);
    setWaitingForPasses(false);
  };

  const submitForm = () => {
    if (waitingSubmit) return;

    var form = document.createElement("form");

    form.method = "POST";
    form.action = "/orders";

    orderItems.forEach((passType) => {
      const quantityInputElement = document.createElement("input");
      quantityInputElement.name = "order[order_items][][quantity]";
      quantityInputElement.value = 1;
      form.appendChild(quantityInputElement);

      const passTypeIdInputElement = document.createElement("input");
      passTypeIdInputElement.name =
        "order[order_items][][day_use_schedule_pass_type_id]";
      passTypeIdInputElement.value = passType.id;
      form.appendChild(passTypeIdInputElement);

      const startTimeInputElement = document.createElement("input");
      startTimeInputElement.name = "order[order_items][][start_time]";
      startTimeInputElement.value = passType.slot.start_time;
      form.appendChild(startTimeInputElement);

      const endTimeInputElement = document.createElement("input");
      endTimeInputElement.name = "order[order_items][][end_time]";
      endTimeInputElement.value = passType.slot.end_time;
      form.appendChild(endTimeInputElement);
    });

    const couponCodeInput = document.createElement("input");
    couponCodeInput.name = "coupon_code";
    couponCodeInput.value = couponCode;
    form.appendChild(couponCodeInput);

    document.body.appendChild(form);

    setWaitingSubmit(true);

    form.submit();
  };

  const addItemToShoppingCart = (passType) => {
    console.log(passType);
    const countOfItensInCart = orderItems.filter((item) => {
      return (
        item.id === passType.id &&
        currentSlot.start_time === item.slot.start_time
      );
    }).length;

    if (countOfItensInCart >= passType.available_quantity) return;

    setOrderItems([...orderItems, { ...passType, key: orderItems.length }]);
  };

  const removeItemFromShoppingCart = (passType) => {
    const currentOrderItems = [...orderItems];
    const index = currentOrderItems.findIndex(
      (item) =>
        item.id === passType.id &&
        currentSlot.start_time === item.slot.start_time
    );

    if (index !== -1) {
      currentOrderItems.splice(index, 1);
      setOrderItems(currentOrderItems);
    }
  };

  const appliedPackage = () => {
    if (dayUsePackages && dayUsePackages.length) {
      let orderItensSortedByPrice = _.cloneDeep(orderItems)
        .sort((a, b) => a.price_in_cents - b.price_in_cents)
        .map(({ applied_package, ...keepAttrs }) => keepAttrs);

      const dayUsePackage = dayUsePackages[0];

      const appliablePasses = orderItensSortedByPrice.filter((pass) =>
        dayUsePackage.day_use_schedule_pass_type_ids.includes(pass.id)
      );
      const countOfPassesToApply =
        Math.floor(appliablePasses.length / dayUsePackage.quantity_of_passes) *
        dayUsePackage.quantity_of_passes;

      if (countOfPassesToApply <= 0 || (couponResult && couponResult.success))
        return;

      return dayUsePackage;
    }
  };

  const calculateCartTotalInCents = () => {
    let orderItensSortedByPrice = _.cloneDeep(orderItems).sort(
      (a, b) => a.price_in_cents - b.price_in_cents
    );

    if (dayUsePackages && dayUsePackages.length) {
      const dayUsePackage = dayUsePackages[0];

      const appliablePasses = orderItensSortedByPrice.filter((pass) =>
        dayUsePackage.day_use_schedule_pass_type_ids.includes(pass.id)
      );
      const countOfPassesToApply =
        Math.floor(appliablePasses.length / dayUsePackage.quantity_of_passes) *
        dayUsePackage.quantity_of_passes;

      if (
        countOfPassesToApply > 0 &&
        (!couponResult || !couponResult.success)
      ) {
        appliablePasses
          .slice(0, countOfPassesToApply)
          .forEach((passToApplyDiscount) => {
            const discountAmount =
              dayUsePackage.kind == "percentage"
                ? (passToApplyDiscount.price_in_cents *
                    dayUsePackage.discount) /
                  100
                : dayUsePackage.discount;
            let newPrice = passToApplyDiscount.price_in_cents - discountAmount;
            if (newPrice <= 0) newPrice = 0;

            passToApplyDiscount.price_in_cents = newPrice;
          });
        orderItensSortedByPrice = appliablePasses;
      }
    }

    return orderItensSortedByPrice.reduce((memo, el) => {
      return memo + el.price_in_cents * (1 + props.feePercentage / 100);
    }, 0);
  };

  const applyCoupon = async (specificCoupon = "") => {
    const response = await axios.get(
      `/api/v1/coupons/${specificCoupon || couponCode || "null"}?entity_id=${
        props.dayUse.id
      }&entity_type=DayUse`
    );
    setCouponResult(response.data);

    const recalculatedSlotsInfosAndQuantities =
      originalSlotsInfosAndQuantities.map((date) => {
        return {
          date: date.date,
          weekday_display: date.weekday_display,
          open_slots_for_date: date.open_slots_for_date.map((slot) => {
            return {
              start_time: slot.start_time,
              end_time: slot.end_time,
              passTypes: slot.passTypes.map((passType) => {
                const discountAmount = response.data.success
                  ? response.data.coupon.kind == "percentage"
                    ? passType.price_in_cents *
                      (response.data.coupon.discount / 100)
                    : response.data.coupon.discount
                  : 0;
                let newPrice = passType.price_in_cents - discountAmount;
                if (newPrice <= 0) newPrice = 0;

                return {
                  id: passType.id,
                  name: passType.name,
                  price_in_cents: newPrice,
                  available_quantity: passType.available_quantity,
                  slot: slot,
                };
              }),
            };
          }),
        };
      });

    setCurrentDate(
      recalculatedSlotsInfosAndQuantities.find(
        (date) => date.date === currentDate.date
      )
    );
    setCurrentSlot(
      recalculatedSlotsInfosAndQuantities
        .map((date) => date.open_slots_for_date)
        .flat()
        .find((slot) => slot.start_time === currentSlot.start_time)
    );
    setAvailablePassTypes(recalculatedSlotsInfosAndQuantities);

    const currentOrderItems = [...orderItems];
    currentOrderItems.forEach((item) => {
      item.price_in_cents = recalculatedSlotsInfosAndQuantities
        .map((date) => date.open_slots_for_date)
        .flat()
        .map((slot) => slot.passTypes)
        .flat()
        .find(
          (passType) =>
            passType.id === item.id &&
            passType.slot.start_time === item.slot.start_time
        ).price_in_cents;
    });
    setOrderItems(currentOrderItems);
  };

  useEffect(() => {
    if (!originalSlotsInfosAndQuantities) return;

    const queryString = window.location.search;
    const urlParams = new URLSearchParams(queryString);
    const couponCodeFromParams = urlParams.get("coupon_code");

    if (couponCodeFromParams) {
      setCouponCode(couponCodeFromParams);
      applyCoupon(couponCodeFromParams);
    }
  }, [originalSlotsInfosAndQuantities]);

  const feeInCents = (passType) => {
    return (
      (passType.price_in_cents / 100) * (parseFloat(props.feePercentage) / 100)
    );
  };

  const changeDate = (amount) => {
    const currentDateIndex = availablePassTypes.findIndex(
      (date) => date === currentDate
    );
    if (
      currentDateIndex + amount < 0 ||
      currentDateIndex + amount >= availablePassTypes.length
    )
      return;
    const newCurrentDate = availablePassTypes[currentDateIndex + amount];
    setCurrentDate(newCurrentDate);

    const slotToRecover = newCurrentDate.open_slots_for_date.find((slot) => {
      return (
        moment(slot.start_time).strftime("%H:%M") ===
        moment(recoverSlotTime).strftime("%H:%M")
      );
    });
    setCurrentSlot(
      slotToRecover ||
        availablePassTypes[currentDateIndex + amount].open_slots_for_date[0]
    );
  };
  
  const changeWeekAvailable = (amount) => {
    return availablePassTypes.find((date) => {
      return moment(date.date).format("YYYY-MM-DD") === moment(currentDate.date).add(amount, "weeks").format(
        "YYYY-MM-DD"
      );
    })
  }

  const changeWeek = (amount) => {
    const newCurrentDate = availablePassTypes.find((date) => {
      return moment(date.date).format("YYYY-MM-DD") === moment(currentDate.date).add(amount, "weeks").format(
        "YYYY-MM-DD"
      );
    })

    if (!newCurrentDate) return;

    setCurrentDate(newCurrentDate);

    const slotToRecover = newCurrentDate.open_slots_for_date.find((slot) => {
      return (
        moment(slot.start_time).strftime("%H:%M") ===
        moment(recoverSlotTime).strftime("%H:%M")
      );
    });
    setCurrentSlot(
      slotToRecover ||
        availablePassTypes[currentDateIndex + amount].open_slots_for_date[0]
    );
  }

  const changeSlot = (amount) => {
    const currentSlotIndex = currentDate.open_slots_for_date.findIndex(
      (slot) => slot === currentSlot
    );
    if (
      currentSlotIndex + amount < 0 ||
      currentSlotIndex + amount >= currentDate.open_slots_for_date.length
    )
      return;
    const updatedSlot =
      currentDate.open_slots_for_date[currentSlotIndex + amount];
    setCurrentSlot(updatedSlot);
    setRecoverSlotTime(updatedSlot.start_time);
  };

  return (
    <div className="event-batches-order">
      <div className="header bg-primary-color p-4">
        <p className="mb-0 fw-700 text-white">
          Ingressos para {props.dayUse.name}
        </p>
      </div>

      {!waitingForPasses ? (
        <div>
          <div className="border border-white p-4 flex center justify-content-center">
            <div
              className={`flex center between ${
                window.mobileMode() ? "w-100" : "w-30"
              }`}
            >
              <div className={`flex center between w-100`}>
                <i
                  className={`f-10 fas fa-forward rotate-180 fs-48 ${
                    changeWeekAvailable(-1)
                      ? "text-success clickable"
                      : "text-secondary"
                  }`}
                  onClick={() => changeWeek(-1)}
                ></i>
                <i
                  className={`f-10 fa fa-caret-left text-end fs-60 ${
                    currentDate.date !==
                    availablePassTypes[0].date
                      ? "text-success clickable"
                      : "text-secondary"
                  }`}
                  onClick={() => changeDate(-1)}
                ></i>
                <p className="f-50 m-0 text-center fs-18 text-white">
                  {moment(currentDate.date).strftime("%d/%m/%Y")}
                  <br />
                  {currentDate &&
                  new Date(currentDate.date).toDateString() ===
                    new Date().toDateString()
                    ? " (Hoje)"
                    : currentDate.weekday_display}
                </p>
                <i
                  className={`f-10 fa fa-caret-right fs-60 ${
                    currentDate.date !==
                    availablePassTypes[availablePassTypes.length - 1].date
                      ? "text-success clickable"
                      : "text-secondary"
                  }`}
                  onClick={() => changeDate(1)}
                ></i>
                <i
                  className={`f-10 fas fa-forward fs-48 ${
                    changeWeekAvailable(1)
                      ? "text-success clickable"
                      : "text-secondary"
                  }`}
                  onClick={() => changeWeek(1)}
                ></i>
              </div>
            </div>
          </div>

          {currentDate &&
          currentDate.open_slots_for_date &&
          currentDate.open_slots_for_date.length > 1 ? (
            <div className="border border-white p-4 flex center justify-content-center">
              <div
                className={`flex center between ${
                  window.mobileMode() ? "w-100" : "w-30"
                }`}
              >
                <p className="m-0 fs-20 text-white f-20">Horário:</p>
                <div className="flex center between f-70">
                  <i
                    className={`f-10 fa fa-caret-left fs-60 ${
                      currentSlot.start_time !==
                      availablePassTypes[0].start_time
                        ? "text-success clickable"
                        : "text-secondary"
                    }`}
                    onClick={() => changeSlot(-1)}
                  ></i>
                  <p className="f-80 m-0 text-center fs-18 text-white">
                    {moment(currentSlot.start_time).strftime("%H:%M")} -{" "}
                    {moment(currentSlot.end_time).strftime("%H:%M")}
                  </p>
                  <i
                    className={`f-10 fa fa-caret-right fs-60 ${
                      currentSlot.start_time !==
                      availablePassTypes[availablePassTypes.length - 1]
                        .start_time
                        ? "text-success clickable"
                        : "text-secondary"
                    }`}
                    onClick={() => changeSlot(1)}
                  ></i>
                </div>
              </div>
            </div>
          ) : (
            <>
              {currentDate.open_slots_for_date.length == 0 && (
                <div className="border border-white p-4 flex center justify-content-center">
                  <p className="p-5">
                    Nenhum ingresso disponível para esta data.
                  </p>
                </div>
              )}
            </>
          )}

          <div className="body border-white border">
            {currentSlot &&
              currentSlot.passTypes &&
              currentSlot.passTypes.map((passType) => {
                return (
                  <div className="border-bottom border-white p-4 flex center between">
                    <div className="f-60">
                      <p className="m-0 f-10 text-white">
                        {moment(currentSlot.start_time).strftime("%d/%m/%Y")} -{" "}
                        {moment(currentSlot.start_time).strftime("%H:%M")} -{" "}
                        {moment(currentSlot.end_time).strftime("%H:%M")} -{" "}
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
                        onClick={() => removeItemFromShoppingCart(passType)}
                      ></i>
                      <p className="m-0 text-white">
                        {
                          orderItems.filter((item) => {
                            return (
                              item.id === passType.id &&
                              currentSlot.start_time === item.slot.start_time
                            );
                          }).length
                        }
                      </p>
                      <i
                        className="fa fa-plus-circle fs-30 text-white clickable"
                        onClick={() => addItemToShoppingCart(passType)}
                      ></i>
                    </div>
                  </div>
                );
              })}
            {currentSlot &&
              currentSlot.passTypes &&
              currentSlot.passTypes.length <= 0 && (
                <div className="border-bottom border-white p-4 flex center between">
                  <p className="p-5">
                    Nenhum ingresso disponível para este horário.
                  </p>
                </div>
              )}

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
                        <p className="m-0 text-danger">
                          {couponResult.message}
                        </p>
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

          <p className="text-center text-white mt-5">Resumo do pedido</p>

          <p className="text-center text-white mt-1">
            <i className="fas fa-shopping-cart fs-30 mr-3"></i>
            <span className="px-3">
              {(calculateCartTotalInCents() / 100).toLocaleString("pt-BR", {
                style: "currency",
                currency: "BRL",
              })}
            </span>
          </p>
          {appliedPackage() && (
            <div className="flex center around gap-24 mb-3">
              <p className="m-0 text-success">
                <i className="fa fa-check-circle f-24 text-success me-3"></i>
                {`Pacote aplicado: ${appliedPackage().description}`}
              </p>
            </div>
          )}
          {orderItems.map((orderItem) => {
            return (
              <p className="text-center text-white fs-14">
                {orderItem.name} -{" "}
                {moment(orderItem.slot.start_time).strftime("%d/%m/%Y")} -{" "}
                {moment(orderItem.slot.start_time).strftime("%H:%M")} -{" "}
                {moment(orderItem.slot.end_time).strftime("%H:%M")}
              </p>
            );
          })}

          <div class="text-center">
            <p
              class={`btn btn-success w-100 mt-2 p-3 ${
                waitingSubmit && "disabled"
              }`}
              onClick={submitForm}
            >
              Comprar ingressos
            </p>
          </div>
          <div class="text-center">
            <p
              class={`btn btn-secondary w-100 mt-2 p-3 ${
                waitingSubmit && "disabled"
              }`}
              onClick={() => {
                setOrderItems([]);
              }}
            >
              Resetar carrinho
            </p>
          </div>
        </div>
      ) : (
        <div className="flex center justify-content-around mt-4">
          <div className="flex center gap-24">
            <TailSpin
              type="TailSpin"
              color="#00C454"
              height={mobileMode() ? 50 : 125}
              width={mobileMode() ? 50 : 125}
            />
            <p className="gs-230 mt-3">Carregando ingressos...</p>
          </div>
        </div>
      )}
    </div>
  );
}
