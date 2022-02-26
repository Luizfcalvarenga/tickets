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
            price_in_cents: passType.price_in_cents
          }
        })
      };
    })
  );

  const updateQuantity = (slotIndex, passTypeName, amount) => {
    const currentSlots = [...slotsInfosAndQuantities];

    const editedSlotItem = currentSlots[slotIndex];

    
    const editedPassType = editedSlotItem.passTypes.find((passType) => {
      return passType.name === passTypeName;
    })

    if (editedPassType.quantity === 0 && amount < 0) return;

    editedPassType.quantity = editedPassType.quantity + amount;

    setSlotsInfosAndQuantities(currentSlots);
  };

  const cartTotalInCents = () => {
    return (
      slotsInfosAndQuantities
      .map((sl) => sl.passTypes)
      .flat()
      .reduce((memo, el) => memo + el.price_in_cents * el.quantity * (1 + props.feePercentage/100), 0)
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

  const feeInCents = (passType) => {
    return (
      (passType.price_in_cents / 100) *
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
            <div>
              {slot.passTypes.map((passType) => {
                return (
                  <div className="border-bottom border-white p-4 flex center between">
                    <p className="m-0 f-10">
                      {moment(slot.start_time).strftime("%H:%M")} -{" "}
                      {moment(slot.end_time).strftime("%H:%M")}
                    </p>
                    <p className="m-0 f-50">{passType.name}</p>
                    <p className="m-0 f-20">
                      {(passType.price_in_cents / 100).toLocaleString("pt-BR", {
                        style: "currency",
                        currency: "BRL",
                      })}
                      &nbsp;(+&nbsp;
                      {feeInCents(passType).toLocaleString("pt-BR", {
                        style: "currency",
                        currency: "BRL",
                      })}{" "}
                      taxa)
                    </p>
                    <div className="flex center around f-10">
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
              { slot.passTypes.length <= 0 && 
                <p>Nenhum tipo de ingresso disponível.</p>
              }
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
