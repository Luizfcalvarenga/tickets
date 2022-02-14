import React, { useEffect, useState } from "react";
import moment from "moment-strftime";

export function DayUseOrderItems(props) {
  const [quantity, setQuantity] = useState(0);

  const updateQuantity = (amount) => {
    if (quantity === 0 && amount < 0) return;

    setQuantity(quantity + amount);
  };

  const cartTotalInCents = () => {
    return props.dayUseSchedule.price_in_cents * quantity;
  };

  const startTime = () => {
    const date = new Date(props.date)
    var userTimezoneOffset = date.getTimezoneOffset() * 60000;
    const timeObject = new Date(date.getTime() + userTimezoneOffset);

    timeObject.setHours(
      new Date(props.dayUseSchedule.start_time).getHours(),
      new Date(props.dayUseSchedule.start_time).getMinutes()
    );

    return timeObject;
  };
  const endTime = () => {
    const date = new Date(props.date);
    var userTimezoneOffset = date.getTimezoneOffset() * 60000;
    const timeObject = new Date(date.getTime() + userTimezoneOffset);

    timeObject.setHours(
      new Date(props.dayUseSchedule.end_time).getHours(),
      new Date(props.dayUseSchedule.end_time).getMinutes()
    );

    return timeObject;
  };

  return (
    <div className="event-batches-order">
      <div className="header bg-primary-color p-4">
        <p className="mb-0 fw-700">Ingressos</p>
      </div>

      <div className="body border-white border">
        <div className="border-bottom border-white p-4 flex center between">
          <p className="m-0 f-60">
            {props.dayUse.name} - {props.dayUseSchedule.name}
             - {moment(startTime()).strftime("%d/%m/%Y")}
          </p>
          <p className="m-0 f-20">
            {(props.dayUseSchedule.price_in_cents / 100).toLocaleString(
              "pt-BR",
              {
                style: "currency",
                currency: "BRL",
              }
            )}
          </p>
          <div className="flex center around f-10">
            <i
              className="fa fa-minus-circle fs-30 text-white clickable"
              onClick={() => updateQuantity(-1)}
            ></i>
            <p className="m-0 text-white">{quantity}</p>
            <i
              className="fa fa-plus-circle fs-30 text-white clickable"
              onClick={() => updateQuantity(1)}
            ></i>
          </div>

          <input
            type="hidden"
            name="order[order_items][][quantity]"
            value={quantity}
          />
          <input
            type="hidden"
            name="order[order_items][][day_use_schedule_id]"
            value={props.dayUseSchedule.id}
          />
          <input
            type="hidden"
            name="order[order_items][][start_time]"
            value={startTime()}
          />
          <input
            type="hidden"
            name="order[order_items][][end_time]"
            value={endTime()}
          />
          <input
            type="hidden"
            name="order[order_items][][price_in_cents]"
            value={props.dayUseSchedule.price_in_cents}
          />
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
