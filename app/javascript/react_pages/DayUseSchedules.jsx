import React, { useState } from "react";
import ReactDOM from "react-dom";
import DateTimePicker from "react-datetime-picker";

export function DayUseSchedules(props) {
  const [activeWeekday, setActiveWeekday] = useState("monday");

  const [weekdays, setWeekdays] = useState([
    { value: "monday", label: "Segunda-feira", passTypes: [] },
    { value: "tuesday", label: "Terça-feira", passTypes: [] },
    { value: "wednesday", label: "Quarta-feira", passTypes: [] },
    { value: "thursday", label: "Quinta-feira", passTypes: [] },
    { value: "friday", label: "Sexta-feira", passTypes: [] },
    { value: "saturday", label: "Sábado", passTypes: [] },
    { value: "sunday", label: "Domingo", passTypes: [] },
  ]);

  const addPassType = (weekday) => {
    const currentWeekdays = [...weekdays];

    const editedWeekday = currentWeekdays.find(
      (currentWeekday) => currentWeekday.name === weekday.name
    );

    editedWeekday.passTypes = [
      ...editedWeekday.passTypes,
      {
        id: null,
        name: "",
        priceInCents: 0,
        dayUseScheduleId: null,
      },
    ];

    setWeekdays(currentWeekdays);
  };

  const removePassType = (weekday, passTypeIndex) => {
    const currentWeekdays = [...weekdays];

    console.log(weekday)

    const editedWeekday = currentWeekdays.find(
      (currentWeekday) => currentWeekday.name === weekday.name
    );

    editedWeekday.passTypes.splice(passTypeIndex, 1);

    setWeekdays(currentWeekdays);
  };

  return (
    <div className="">
      <p className="m-0 info-text p-4 br-8 mb-3">
        <i className="fa fa-info-circle mx-3"></i>Para um day-use ser
        considerado aberto no dia, é necessário preencher um horário de abertura
        e um horário de fechamento. Para deixar o day-use fechado em algum dia
        da semana, não preencha as informações de horário.
      </p>

      <p className="m-0 info-text p-4 br-8 mb-3">
        <i className="fa fa-info-circle mx-3"></i>Para um day-use ter apenas um slot diário, não é necessário preencher o campo "Duração do slot"
      </p>

      <ul className="nav nav-tabs mb-5" id="myTab" role="tablist">
        {weekdays.map((weekday) => {
          return (
            <li className="nav-item" role="presentation">
              <button
                className={`nav-link ${weekday.value === "monday" && "active"}`}
                id={`${weekday.value}-tab`}
                data-bs-toggle="tab"
                data-bs-target={`#weekday-${weekday.value}`}
                type="button"
                role="tab"
                aria-controls="home"
                aria-selected="true"
              >
                {weekday.label}
              </button>
            </li>
          );
        })}
      </ul>

      <div className="tab-content">
        {weekdays.map((weekday) => {
          return (
            <div
              className={`tab-pane fade show ${
                weekday.value === "monday" && "active"
              }`}
              id={`weekday-${weekday.value}`}
              role="tabpanel"
              aria-labelledby="home-tab"
            >
              <input
                className="form-control my-2"
                type="hidden"
                name="day_use[day_use_schedules][][weekday]"
                value={weekday.value}
              ></input>
              <div className="bg-dark p-4 br-8 mb-2">
                <div>
                  <input
                    className="form-control my-2 f-40"
                    type="text"
                    name="day_use[day_use_schedules][][name]"
                    placeholder="Nome"
                  />
                  <textarea
                    class="form-control my-2 f-60"
                    type="text"
                    name="day_use[day_use_schedules][][description]"
                    placeholder="Descrição do dia"
                  />
                  <div className="flex center between">
                    <div className="f-48 flex center around gap-16">
                      <input
                        className="form-control my-2"
                        type="time"
                        name="day_use[day_use_schedules][][opens_at]"
                        placeholder="Horário início"
                      />
                      <p className="m-0">até</p>
                      <input
                        className="form-control my-2"
                        type="time"
                        name="day_use[day_use_schedules][][closes_at]"
                        placeholder="Horário fim"
                      />
                    </div>
                    <div className="f-48 flex center gap-24">
                      <input
                        className="form-control my-2"
                        type="text"
                        name="day_use[day_use_schedules][][slot_duration_in_minutes]"
                        placeholder="Duração do slot"
                      />
                      <input
                        className="form-control my-2"
                        type="text"
                        name="day_use[day_use_schedules][][quantity_per_slot]"
                        placeholder="Limite de ingressos por slot"
                      />
                    </div>
                  </div>
                </div>

                {weekday.passTypes.map((passType, passTypeIndex) => {
                  return (
                    <div className="mb-4" key={passTypeIndex}>
                      <input
                        type="hidden"
                        name="day_use[day_use_schedules][][pass_types][][id]"
                        value={passType.id}
                      />
                      <div className="flex center between gap-24">
                        <input
                          class="form-control my-2"
                          type="text"
                          name="day_use[day_use_schedules][][pass_types][][name]"
                          placeholder="Tipo de ingresso"
                        />
                        <input
                          class="form-control my-2"
                          type="number"
                          name="day_use[day_use_schedules][][pass_types][][price_in_cents]"
                          placeholder="Preço em centavos"
                        />
                        <p
                          className="btn btn-danger w-20 text-center"
                          onClick={() => removePassType(weekday, passTypeIndex)}
                        >
                          <i className="fa fa-trash text-white"></i>
                          <span className="px-3 text-white">Remover</span>
                        </p>
                      </div>
                    </div>
                  );
                })}

                <p
                  className="btn btn-primary p-3 w-100 text-center mt-5"
                  onClick={() => addPassType(weekday)}
                >
                  <i className="fa fa-plus"></i>
                  <span className="px-3">Adicionar tipo de ingresso</span>
                </p>
              </div>
            </div>
          );
        })}
      </div>
    </div>
  );
}
