import React, { useEffect, useState } from "react";
import moment from "moment-strftime";

export function DayUseOrderItems(props) {
  const [slotsInfosAndQuantities, setSlotsInfosAndQuantities] = useState(
    props.openSlots.map((slot) => {
      return {
        id: slot.id,
        start_time: slot.start_time,
        end_time: slot.end_time,
        quantity: 0,
      };
    })
  );

  const updateQuantity = (slotIndex, amount) => {
    const currentSlots = [...slotsInfosAndQuantities];

    const editedSlotItem = currentSlots[slotIndex];

    if (editedSlotItem.quantity === 0 && amount < 0) return;

    currentSlots[slotIndex].quantity =
      currentSlots[slotIndex].quantity + amount;

    setSlotsInfosAndQuantities(currentSlots);
  };

  useEffect(() => {
    const totalQuantity = slotsInfosAndQuantities.reduce(
      (memo, el) => memo + parseInt(el.quantity, 10), 0
    );
    console.log(totalQuantity)
    console.log(
      props.dayUseSchedule.price_in_cents *
      totalQuantity *
      (1 + props.feePercentage / 100)
    );
  })

  const cartTotalInCents = () => {
    const totalQuantity = slotsInfosAndQuantities.reduce(
      (memo, el) => memo + parseInt(el.quantity, 10),
      0
    );
    return (
      props.dayUseSchedule.price_in_cents *
      totalQuantity *
      (1 + props.feePercentage / 100)
    );
  };

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
  const endTime = () => {
    const date = new Date(props.date);
    var userTimezoneOffset = date.getTimezoneOffset() * 60000;
    const timeObject = new Date(date.getTime() + userTimezoneOffset);

    timeObject.setHours(
      new Date(props.dayUseSchedule.closes_at).getHours(),
      new Date(props.dayUseSchedule.closes_at).getMinutes()
    );

    return timeObject;
  };
  const feeInCents = () => {
    return (
      (props.dayUseSchedule.price_in_cents / 100) *
      (parseFloat(props.feePercentage) / 100)
    );
  };

  return (
    <div className="event-batches-order">
      <div className="header bg-primary-color p-4">
        <p className="mb-0 fw-700">
          Ingressos para {moment(startTime()).strftime("%d/%m/%Y")}
        </p>
      </div>

      <div className="body border-white border">
        {slotsInfosAndQuantities.map((slot, index) => {
          return (
            <div className="border-bottom border-white p-4 flex center between">
              <p className="m-0 f-60">
                {moment(slot.start_time).strftime("%H:%M")} -{" "}
                {moment(slot.end_time).strftime("%H:%M")}
              </p>
              <p className="m-0 f-20">
                {(props.dayUseSchedule.price_in_cents / 100).toLocaleString(
                  "pt-BR",
                  {
                    style: "currency",
                    currency: "BRL",
                  }
                )}
                &nbsp;(+&nbsp;
                {feeInCents().toLocaleString("pt-BR", {
                  style: "currency",
                  currency: "BRL",
                })}{" "}
                taxa)
              </p>
              <div className="flex center around f-10">
                <i
                  className="fa fa-minus-circle fs-30 text-white clickable"
                  onClick={() => updateQuantity(index, -1)}
                ></i>
                <p className="m-0 text-white">{slot.quantity}</p>
                <i
                  className="fa fa-plus-circle fs-30 text-white clickable"
                  onClick={() => updateQuantity(index, 1)}
                ></i>
              </div>

              <input
                type="hidden"
                name="order[order_items][][quantity]"
                value={slot.quantity}
              />
              <input
                type="hidden"
                name="order[order_items][][day_use_schedule_id]"
                value={props.dayUseSchedule.id}
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
