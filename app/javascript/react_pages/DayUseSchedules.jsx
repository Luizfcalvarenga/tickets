import React, { useState } from "react";

export function DayUseSchedules(props) {
  const weekdaysPrep = [
    {
      value: "monday",
      label: "Segunda-feira",
      dayUseSchedule: props.dayUseSchedules.find(
        (dus) => dus.weekday === "monday"
      ),
    },
    {
      value: "tuesday",
      label: "Terça-feira",
      dayUseSchedule: props.dayUseSchedules.find(
        (dus) => dus.weekday === "tuesday"
      ),
    },
    {
      value: "wednesday",
      label: "Quarta-feira",
      dayUseSchedule: props.dayUseSchedules.find(
        (dus) => dus.weekday === "wednesday"
      ),
    },
    {
      value: "thursday",
      label: "Quinta-feira",
      dayUseSchedule: props.dayUseSchedules.find(
        (dus) => dus.weekday === "thursday"
      ),
    },
    {
      value: "friday",
      label: "Sexta-feira",
      dayUseSchedule: props.dayUseSchedules.find(
        (dus) => dus.weekday === "friday"
      ),
    },
    {
      value: "saturday",
      label: "Sábado",
      dayUseSchedule: props.dayUseSchedules.find(
        (dus) => dus.weekday === "saturday"
      ),
    },
    {
      value: "sunday",
      label: "Domingo",
      dayUseSchedule: props.dayUseSchedules.find(
        (dus) => dus.weekday === "sunday"
      ),
    },
  ];
  weekdaysPrep.forEach((wp) => {
    var match = /T(\d{2}:\d{2})/.exec(
      wp.dayUseSchedule.opens_at
    );
    wp.dayUseSchedule.opens_at = match ? match[1] : null;
    var match = /T(\d{2}:\d{2})/.exec(wp.dayUseSchedule.closes_at);
    wp.dayUseSchedule.closes_at = match ? match[1] : null;
  })
  const [weekdays, setWeekdays] = useState(weekdaysPrep);

  const addPassType = (weekday) => {
    const currentWeekdays = [...weekdays];

    const editedWeekday = currentWeekdays.find(
      (currentWeekday) => currentWeekday.value === weekday.value
    );
    
    editedWeekday.dayUseSchedule.day_use_schedule_pass_types = [
      ...editedWeekday.dayUseSchedule.day_use_schedule_pass_types,
      {
        id: null,
        name: "",
        deleted_at: null,
        priceInCents: 0,
        dayUseScheduleId: null,
      },
    ];

    setWeekdays(currentWeekdays);
  };

  const handlePassTypeUpdate = (field, value, weekday, passTypeIndex) => {
    const currentWeekdays = [...weekdays];

    console.log(weekday);

    const editedWeekday = currentWeekdays.find(
      (currentWeekday) => currentWeekday.value === weekday.value
    );

    editedWeekday.dayUseSchedule.day_use_schedule_pass_types[passTypeIndex][field] = value

    setWeekdays(currentWeekdays);
  }

  const removePassType = (weekday, passTypeIndex) => {
    const currentWeekdays = [...weekdays];

    const editedWeekday = currentWeekdays.find(
      (currentWeekday) => currentWeekday.value === weekday.value
    );

     editedWeekday.dayUseSchedule.day_use_schedule_pass_types.splice(
       passTypeIndex,
       1
     );

    setWeekdays(currentWeekdays);
  };

  const handleWeekdayChange = (field, value, weekdayIndex) => {
    const currentWeekdays = [...weekdays];

    currentWeekdays[weekdayIndex].dayUseSchedule[field] = value;

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
        <i className="fa fa-info-circle mx-3"></i>Para um day-use ter apenas um
        slot diário, não é necessário preencher o campo "Duração do slot"
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
        {weekdays.map((weekday, index) => {
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
                  <label htmlFor="">Nome</label>
                  <input
                    className="form-control my-2 f-40"
                    type="text"
                    name="day_use[day_use_schedules][][name]"
                    placeholder="Nome"
                    value={weekday.dayUseSchedule.name}
                    onChange={(e) =>
                      handleWeekdayChange("name", e.target.value, index)
                    }
                  />
                  <label htmlFor="">Descrição</label>
                  <textarea
                    class="form-control my-2 f-60"
                    type="text"
                    name="day_use[day_use_schedules][][description]"
                    placeholder="Descrição do dia"
                    value={weekday.dayUseSchedule.description}
                    onChange={(e) =>
                      handleWeekdayChange("description", e.target.value, index)
                    }
                  />
                  <div className="flex center between">
                    <div className="f-48">
                      <label htmlFor="">Horário de funcionamento</label>
                      <div className="f-48 flex center around gap-16">
                        <input
                          className="form-control my-2"
                          type="time"
                          name="day_use[day_use_schedules][][opens_at]"
                          placeholder="Horário início"
                          value={weekday.dayUseSchedule.opens_at}
                          onChange={(e) =>
                            handleWeekdayChange(
                              "opens_at",
                              e.target.value,
                              index
                            )
                          }
                        />
                        <p className="m-0">até</p>
                        <input
                          className="form-control my-2"
                          type="time"
                          name="day_use[day_use_schedules][][closes_at]"
                          placeholder="Horário fim"
                          value={weekday.dayUseSchedule.closes_at}
                        />
                      </div>
                    </div>
                    <div className="f-48 flex center gap-24">
                      <div class="f-1x">
                        <label htmlFor="">Duração do slot</label>
                        <input
                          className="form-control my-2"
                          type="text"
                          name="day_use[day_use_schedules][][slot_duration_in_minutes]"
                          placeholder="Duração do slot"
                          value={
                            weekday.dayUseSchedule.slot_duration_in_minutes
                          }
                        />
                      </div>
                      <div class="f-1x">
                        <label htmlFor="">Quantidade de passes por slot</label>
                        <input
                          className="form-control my-2"
                          type="text"
                          name="day_use[day_use_schedules][][quantity_per_slot]"
                          placeholder="Limite de ingressos por slot"
                          value={weekday.dayUseSchedule.quantity_per_slot}
                        />
                      </div>
                    </div>
                  </div>
                </div>

                <label htmlFor="">Tipos de passes</label>
                {weekday.dayUseSchedule.day_use_schedule_pass_types.filter((pass_type) => !pass_type.deleted_at).map(
                  (passType, passTypeIndex) => {
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
                            value={passType.name}
                            onChange={(e) =>
                              handlePassTypeUpdate(
                                "name",
                                e.target.value,
                                weekday,
                                passTypeIndex
                              )
                            }
                          />
                          <input
                            class="form-control my-2"
                            type="number"
                            name="day_use[day_use_schedules][][pass_types][][price_in_cents]"
                            placeholder="Preço em centavos"
                            value={passType.price_in_cents}
                            onChange={(e) =>
                              handlePassTypeUpdate(
                                "price_in_cents",
                                e.target.value,
                                weekday.value,
                                passTypeIndex
                              )
                            }
                          />
                          <p
                            className="btn btn-danger w-20 text-center"
                            onClick={() =>
                              removePassType(weekday, passTypeIndex)
                            }
                          >
                            <i className="fa fa-trash text-white"></i>
                            <span className="px-3 text-white">Remover</span>
                          </p>
                        </div>
                      </div>
                    );
                  }
                )}

                <p
                  className="btn btn-success p-3 w-100 text-center mt-5"
                  onClick={() => addPassType(weekday)}
                >
                  <i className="fa fa-plus"></i>
                  <span className="px-3">Adicionar tipo de passe</span>
                </p>
              </div>
            </div>
          );
        })}
      </div>
    </div>
  );
}
