import React, { useState } from "react";
import "flatpickr/dist/themes/material_green.css";
import Flatpickr from "react-flatpickr";
const moment = require("moment-strftime");

export function EventBatches(props) {
  const uniquePassTypes = props.eventBatches
    .map((eb) => eb.pass_type)
    .filter((value, index, self) => self.indexOf(value) === index);

  const [passTypes, setPassTypes] = useState(
    uniquePassTypes.map((passType) => {
      return {
        name: passType,
        event_batches: props.eventBatches.filter(
          (eb) => eb.pass_type === passType
        ),
      };
    })
  );

  const orderToOrdinalArray = [
    "Primeiro",
    "Segundo",
    "Terceiro",
    "Quarto",
    "Quinto",
    "Sexto",
    "Sétimo",
    "Oitavo",
    "Nono",
    "Décimo",
  ];

  const restoreErrorForField = (field, eventBatchFormIdentifier) => {
    if (!props.errors || !props.errors.event_batches) return;

    const eventBatch = props.errors.event_batches.find(
      (eb) => eb.index == eventBatchFormIdentifier
      );
    
    if (!eventBatch) return;

    const eventBatchErrors = eventBatch.error;
    const error =
      eventBatchErrors && eventBatchErrors[field] && eventBatchErrors[field][0];

    return (
      <div className="text-danger">
        <p>{error}</p>
      </div>
    );
  };

  const addEventBatch = (passType) => {
    const currentPassTypes = [...passTypes];

    const editedPassType = currentPassTypes.find(
      (currentPassType) => currentPassType.name === passType.name
    );

    editedPassType.event_batches = [
      ...editedPassType.event_batches,
      {
        pass_type: passType.name,
        name: `${
          orderToOrdinalArray[editedPassType.event_batches.length]
        } lote`,
        quantity: 0,
        price_in_cents: 0,
        number_of_accesses_granted: 1,
        ends_at: moment(Date.new).strftime("%Y-%m-%d"),
        order: editedPassType.event_batches.length,
      },
    ];

    setPassTypes(currentPassTypes);
  };

  const removeEventBatch = (passType, eventBatchIndex) => {
    const currentPassTypes = [...passTypes];

    const editedPassType = currentPassTypes.find(
      (currentPassType) => currentPassType.name === passType.name
    );

    editedPassType.event_batches.splice(eventBatchIndex, 1);

    if (editedPassType.event_batches.length === 0) {
      currentPassTypes.splice(currentPassTypes.indexOf(editedPassType), 1);
    }

    setPassTypes(currentPassTypes);
  };

  const updateEventBatch = (value, field, passType, eventBatchIndex) => {
    const currentPassTypes = [...passTypes];

    const editedPassType = currentPassTypes.find(
      (currentPassType) => currentPassType.name === passType.name
    );

    editedPassType.event_batches[eventBatchIndex][field] = value;

    setPassTypes(currentPassTypes);
  };

  const addPassType = () => {
    setPassTypes([
      ...passTypes,
      {
        name: `Tipo de ingresso ${passTypes.length + 1}`,
        event_batches: [
          {
            pass_type: "",
            name: `${orderToOrdinalArray[0]} lote`,
            quantity: 0,
            price_in_cents: 0,
            number_of_accesses_granted: 1,
            ends_at: Date.new,
            order: 0,
          },
        ],
      },
    ]);
  };

  const handlePassTypeName = (value, elementIndex) => {
    const currentPassTypes = [...passTypes];

    currentPassTypes[elementIndex].name = value;

    setPassTypes(currentPassTypes);
  };

  return (
    <div className="">
      {passTypes.map((passType, index) => {
        return (
          <div key={index} className="mb-4">
            <div>
              <label htmlFor="">Nome do tipo de ingresso</label>
              <input
                className="form-control my-2"
                type="text"
                value={passType.name}
                placeholder="Nome do tipo de ingresso"
                onChange={(e) => handlePassTypeName(e.target.value, index)}
              />
            </div>
            <br></br>
            {passType.event_batches.map((eventBatch, eventBatchIndex) => {
              return (
                <div key={eventBatch.order} className="mb-4">
                  {restoreErrorForField(
                    "pass_type",
                    `${index}-${eventBatchIndex}`
                  )}
                  <input
                    type="hidden"
                    name="event[event_batches][][form_identifier]"
                    value={`${index}-${eventBatchIndex}`}
                  />
                  <input
                    type="hidden"
                    name="event[event_batches][][id]"
                    value={eventBatch.id}
                  />
                  <input
                    type="hidden"
                    name="event[event_batches][][order]"
                    value={eventBatch.order}
                  />
                  <input
                    type="hidden"
                    name="event[event_batches][][pass_type]"
                    value={passType.name}
                  />
                  <div className="flex center between gap-24">
                    <div className="f-1x">
                      <label htmlFor="">Nome</label>
                      <input
                        className="form-control my-2"
                        type="text"
                        value={eventBatch.name}
                        onChange={(e) =>
                          updateEventBatch(
                            e.target.value,
                            "name",
                            passType,
                            eventBatchIndex
                          )
                        }
                        name="event[event_batches][][name]"
                        placeholder="Nome do lote"
                      />
                      {restoreErrorForField(
                        "name",
                        `${index}-${eventBatchIndex}`
                      )}
                    </div>
                    <div className="f-1x">
                      <label htmlFor="">Preço em centavos</label>
                      <input
                        className="form-control my-2"
                        type="text"
                        value={eventBatch.price_in_cents}
                        onChange={(e) =>
                          updateEventBatch(
                            e.target.value,
                            "price_in_cents",
                            passType,
                            eventBatchIndex
                          )
                        }
                        name="event[event_batches][][price_in_cents]"
                        placeholder="Preço"
                      />

                      {restoreErrorForField(
                        "price_in_cents",
                        `${index}-${eventBatchIndex}`
                      )}
                    </div>
                    <p
                      className="btn btn-danger w-20 text-center text-white mt-5"
                      onClick={() =>
                        removeEventBatch(passType, eventBatchIndex)
                      }
                    >
                      <i className="fa fa-trash"></i>
                      <span className="px-3">Remover</span>
                    </p>
                  </div>
                  <div className="flex center between gap-24">
                    <div className="f-1x">
                      <label htmlFor="">Quantidade de ingressos</label>
                      <input
                        className="form-control my-2"
                        type="text"
                        name="event[event_batches][][quantity]"
                        value={eventBatch.quantity}
                        onChange={(e) =>
                          updateEventBatch(
                            e.target.value,
                            "quantity",
                            passType,
                            eventBatchIndex
                          )
                        }
                        placeholder="Quantidade máxima de ingressos"
                      />
                      {restoreErrorForField(
                        "quantity",
                        `${index}-${eventBatchIndex}`
                      )}
                    </div>
                    <div className="f-1x">
                      <label htmlFor="">Número de acessos por passe</label>
                      <input
                        className="form-control my-2"
                        type="text"
                        name="event[event_batches][][number_of_accesses_granted]"
                        value={eventBatch.number_of_accesses_granted}
                        onChange={(e) =>
                          updateEventBatch(
                            e.target.value,
                            "number_of_accesses_granted",
                            passType,
                            eventBatchIndex
                          )
                        }
                        placeholder="Número de acessos por passe"
                      />
                      {restoreErrorForField(
                        "number_of_accesses_granted",
                        `${index}-${eventBatchIndex}`
                      )}
                    </div>
                    <div className="f-1x">
                      <label htmlFor="">Data limite</label>
                      <input
                        className="form-control mx-1 date required"
                        type="date"
                        name="event[event_batches][][ends_at]"
                        value={moment(eventBatch.ends_at).strftime("%Y-%m-%d")}
                        onChange={(e) =>
                          updateEventBatch(
                            e.target.value,
                            "ends_at",
                            passType,
                            eventBatchIndex
                          )
                        }
                        id="event_scheduled_start"
                      ></input>
                      {restoreErrorForField(
                        "ends_at",
                        `${index}-${eventBatchIndex}`
                      )}
                    </div>
                  </div>
                </div>
              );
            })}
            <p
              className="btn btn-success text-center"
              onClick={() => addEventBatch(passType)}
            >
              <i className="fa fa-plus-square"></i>
              <span className="px-3">Adicionar lote</span>
            </p>
            <hr />
          </div>
        );
      })}
      <p className="btn btn-success text-center" onClick={addPassType}>
        <i className="fa fa-plus-square"></i>
        <span className="px-3">Criar tipo de ingresso</span>
      </p>
    </div>
  );
}
