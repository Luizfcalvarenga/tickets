import React, { useState } from "react";
import ReactDOM from "react-dom";

export function EventBatches(props) {
  const [passTypes, setPassTypes] = useState([]);

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

  const addEventBatch = (passType) => {
    const currentPassTypes = [...passTypes];

    const editedPassType = currentPassTypes.find(
      (currentPassType) => currentPassType.name === passType.name
    );

    editedPassType.eventBatches = [
      ...editedPassType.eventBatches,
      {
        pass_type: passType.name,
        name: `${orderToOrdinalArray[editedPassType.eventBatches.length]} lote`,
        quantity: 0,
        price_in_cents: 0,
        ends_at: Date.new,
        order: editedPassType.eventBatches.length + 1,
      },
    ];

    setPassTypes(currentPassTypes);
  };

  const removeEventBatch = (passType, eventBatchIndex) => {
    const currentPassTypes = [...passTypes];

    const editedPassType = currentPassTypes.find(
      (currentPassType) => currentPassType.name === passType.name
    );

    console.log(editedPassType.eventBatches.splice(eventBatchIndex, 1));

    // editedPassType.eventBatches = editedPassType.eventBatches.splice(eventBatchIndex, 1)

    // setPassTypes(currentPassTypes);
  };

  const addPassType = () => {
    setPassTypes([
      ...passTypes,
      {
        name: "",
        eventBatches: [
          {
            pass_type: "",
            name: `${orderToOrdinalArray[0]} lote`,
            quantity: 0,
            price_in_cents: 0,
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
              <input
                class="form-control my-2"
                type="text"
                value={passType.name}
                placeholder="Nome do tipo de ingresso"
                onChange={(e) => handlePassTypeName(e.target.value, index)}
              />
            </div>
            <br></br>
            {passType.eventBatches.map((eventBatch, eventBatchIndex) => {
              return (
                <div key={eventBatch.order} className="mb-4">
                  <input
                    type="hidden"
                    name="event_batches[][order]"
                    value={eventBatch.order}
                  />
                  <div className="flex center between gap-24">
                    <input
                      class="form-control my-2"
                      type="text"
                      value={eventBatch.name}
                      name="event_batches[][name]"
                      placeholder="Nome do lote"
                    />
                    <input
                      class="form-control my-2"
                      type="text"
                      name="event_batches[][price_in_cents]"
                      placeholder="Preço"
                    />
                    <p>{eventBatchIndex}</p>
                    <p
                      className="btn btn-danger w-20 text-center"
                      onClick={() =>
                        removeEventBatch(passType, eventBatchIndex)
                      }
                    >
                      <i className="fa fa-trash"></i>
                      <span className="px-3">Remover</span>
                    </p>
                  </div>
                  <div className="flex center between gap-24">
                    <input
                      class="form-control my-2"
                      type="text"
                      name="event_batches[][quantity]"
                      placeholder="Quantidade máxima de ingressos"
                    />
                    <input
                      class="form-control my-2"
                      type="text"
                      name="event_batches[][price_in_cents]"
                      placeholder="Data limite do lote"
                    />
                  </div>
                </div>
              );
            })}
            <p
              className="btn btn-primary p-3 w-100 text-center"
              onClick={() => addEventBatch(passType)}
            >
              <i className="fa fa-plus"></i>
              <span className="px-3">Adicionar lote</span>
            </p>
            <hr />
          </div>
        );
      })}
      <p
        className="btn btn-primary p-3 w-100 text-center"
        onClick={addPassType}
      >
        <i className="fa fa-plus"></i>
        <span className="px-3">Criar tipo de ingresso</span>
      </p>
    </div>
  );
}
