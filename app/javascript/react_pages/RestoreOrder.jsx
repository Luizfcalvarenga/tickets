import React, { useState } from "react";
import { useEffect } from "react";
import ReactDOM from "react-dom";
import { TailSpin } from "react-loader-spinner";

export function RestoreOrder(props) {
  useEffect(() => {
    console.log(props)
    var form = document.createElement("form");

    form.method = "POST";
    form.action = "/orders";
    form.classList = "d-none";

    props.orderParams.order.order_items.forEach((passType) => {
      const quantityInputElement = document.createElement("input");
      quantityInputElement.name = "order[order_items][][quantity]";
      quantityInputElement.value = 1;
      form.appendChild(quantityInputElement);

      const dayUseSchedulePassTypeId = document.createElement("input");
      dayUseSchedulePassTypeId.name =
        "order[order_items][][day_use_schedule_pass_type_id]";
      dayUseSchedulePassTypeId.value = passType.day_use_schedule_pass_type_id;
      form.appendChild(dayUseSchedulePassTypeId);
      
      const eventBatchPassTypeId = document.createElement("input");
      eventBatchPassTypeId.name =
        "order[order_items][][event_batch_id]";
      eventBatchPassTypeId.value = passType.event_batch_id;
      form.appendChild(eventBatchPassTypeId);

      const startTimeInputElement = document.createElement("input");
      startTimeInputElement.name = "order[order_items][][start_time]";
      startTimeInputElement.value = passType.start_time;
      form.appendChild(startTimeInputElement);

      const endTimeInputElement = document.createElement("input");
      endTimeInputElement.name = "order[order_items][][end_time]";
      endTimeInputElement.value = passType.end_time;
      form.appendChild(endTimeInputElement);
    });

    // const couponCodeInput = document.createElement("input");
    // couponCodeInput.name = "coupon_code";
    // couponCodeInput.value = couponCode;
    // form.appendChild(couponCodeInput);

    document.body.appendChild(form);

    form.submit();
  }, []);

  return (
    <div className="vh-100 flex center around">
      <div className="flex center gap-24">
        <TailSpin
          type="TailSpin"
          color="#00C454"
          height={mobileMode() ? 50 : 125}
          width={mobileMode() ? 50 : 125}
        />
        <p className="gs-230 mt-3">Recuperando sua compra...</p>
      </div>
    </div>
  );
}
