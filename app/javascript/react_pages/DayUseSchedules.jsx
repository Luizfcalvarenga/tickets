import React, { useState } from "react";

export function DayUseSchedules(props) {
  const buildEmptyDayUseSchedule = (weekdayName) => {
    return {
      name: "",
      opens_at: "",
      closes_at: "",
      description: "",
      slot_duration_in_minutes: null,
      quantity_per_slot: null,
      day_use_schedule_pass_types: [],
      weekday: weekdayName,
    };
  };
  const weekdaysTranslation = {
    monday: "Segunda-feira",
    tuesday: "Terça-feira",
    wednesday: "Quarta-feira",
    thursday: "Quinta-feira",
    friday: "Sexta-feira",
    saturday: "Sábado",
    sunday: "Domingo",
  };
  const weekdaysArray = [
    "monday",
    "tuesday",
    "wednesday",
    "thursday",
    "friday",
    "saturday",
    "sunday",
  ];

  const weekdaysPrep = weekdaysArray.map((weekday) => {
    const findWeekdayOnProps = props.dayUseSchedules.find(
      (dayUseSchedule) => dayUseSchedule.weekday === weekday
    );
    if (
      findWeekdayOnProps &&
      (!findWeekdayOnProps.day_use_schedule_pass_types ||
        !findWeekdayOnProps.day_use_schedule_pass_types.length === 0)
    ) {
      findWeekdayOnProps.day_use_schedule_pass_types = [];
    }

    return {
      value: weekday,
      label: weekdaysTranslation[weekday],
      dayUseSchedule: findWeekdayOnProps
        ? { ...findWeekdayOnProps }
        : buildEmptyDayUseSchedule(weekday),
    };
  });

  weekdaysPrep.forEach((wp) => {
    if (!wp.dayUseSchedule) return;

    if (wp.dayUseSchedule.opens_at && !wp.dayUseSchedule.opens_at.match(/^([0-1]?[0-9]|2[0-3]):[0-5][0-9]$/)) {
      var match = /T(\d{2}:\d{2})/.exec(wp.dayUseSchedule.opens_at);
      wp.dayUseSchedule.opens_at = match ? match[1] : null;
    }
    if (wp.dayUseSchedule.opens_at && !wp.dayUseSchedule.closes_at.match(/^([0-1]?[0-9]|2[0-3]):[0-5][0-9]$/)) {
      var match = /T(\d{2}:\d{2})/.exec(wp.dayUseSchedule.closes_at);
      wp.dayUseSchedule.closes_at = match ? match[1] : null;
    }
  });

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
        number_of_accesses_granted: 1,
        priceInCents: 0,
        dayUseScheduleId: null,
      },
    ];

    setWeekdays(currentWeekdays);
  };

  const handlePassTypeUpdate = (field, value, weekday, passTypeIndex) => {
    const currentWeekdays = [...weekdays];

    const editedWeekday = currentWeekdays.find(
      (currentWeekday) => currentWeekday.value === weekday.value
    );

    
    editedWeekday.dayUseSchedule.day_use_schedule_pass_types.filter(
      (pass_type) => !pass_type.deleted_at
    )[passTypeIndex][field] = value;

    setWeekdays(currentWeekdays);
  };

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

  const restoreErrorForField = (field, weekday) => {
    if (!props.errors || !props.errors.day_use_schedules) return;

    const dayUseSchedule = props.errors.day_use_schedules.find(
      (eb) => eb.weekday == weekday
    );

    if (!dayUseSchedule) return;

    const dayUseScheduleErrors = dayUseSchedule.error;
    const error =
      dayUseScheduleErrors &&
      dayUseScheduleErrors[field] &&
      dayUseScheduleErrors[field][0];

    return (
      <div className="text-danger">
        <p>{error}</p>
      </div>
    );
  };
  const restoreErrorForPassTypeField = (field, weekday, passTypeIndex) => {
    if (!props.errors || !props.errors.day_use_schedules) return;

    const dayUseSchedule = props.errors.day_use_schedules.find(
      (eb) => eb.weekday == weekday
    );

    if (!dayUseSchedule) return;

    const dayUseSchedulePassTypeErrors =
      dayUseSchedule &&
      dayUseSchedule.pass_types &&
      dayUseSchedule.pass_types[passTypeIndex] &&
      dayUseSchedule.pass_types[passTypeIndex][field];

    if (!dayUseSchedulePassTypeErrors) return;

    return (
      <div className="text-danger">
        <p>{dayUseSchedulePassTypeErrors[0]}</p>
      </div>
    );
  };

  return (
    <div className="">
      <p className="m-0 info-text p-4 br-8 mb-3">
        <i className="fa fa-info-circle mx-3"></i>Para um agendamento ser
        considerado aberto no dia, é necessário preencher um horário de abertura
        e um horário de fechamento. Para deixar o agendamento fechado em algum
        dia da semana, não preencha as informações de horário.
      </p>

      <p className="m-0 info-text p-4 br-8 mb-3">
        <i className="fa fa-info-circle mx-3"></i>Para um agendamento ter apenas
        um slot diário, não é necessário preencher o campo "Duração do slot"
      </p>

      {props.errors &&
        props.errors.day_use_schedules &&
        props.errors.day_use_schedules.length > 0 && (
          <p className="m-0 danger-text p-4 br-8 mb-3">
            <i className="fa fa-exclamation-triangle mx-3"></i>Houve erro no
            agendamento de algum dia. Verifique os dias de semana com o símbolo
            de erro abaixo.
          </p>
        )}

      <ul className="nav nav-tabs mb-5" id="myTab" role="tablist">
        {weekdays.map((weekday) => {
          return (
            <li className="nav-item position-relative" role="presentation">
              <button
                className={`nav-link position-relative ${
                  weekday.value === "monday" && "active"
                }`}
                id={`${weekday.value}-tab`}
                data-bs-toggle="tab"
                data-bs-target={`#weekday-${weekday.value}`}
                type="button"
                role="tab"
                aria-controls="home"
                aria-selected="true"
              >
                {weekday.label}
              </button>{" "}
              {props.errors &&
                props.errors.day_use_schedules &&
                props.errors.day_use_schedules.find(
                  (eb) => eb.weekday == weekday.value
                ) && <div className="danger-dot">!</div>}
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
                  {restoreErrorForField("name", weekday.value)}
                  <label htmlFor="">Descrição</label>
                  <textarea
                    className="form-control my-2 f-60"
                    type="text"
                    name="day_use[day_use_schedules][][description]"
                    placeholder="Descrição do dia"
                    value={weekday.dayUseSchedule.description}
                    onChange={(e) =>
                      handleWeekdayChange("description", e.target.value, index)
                    }
                  />
                  <div className="form-group file optional day_use_photo form-group-valid">
                    <label className="file optional" for="day_use_photo">
                      Foto específica do dia
                    </label>
                    <input
                      className="form-control-file is-valid file optional"
                      type="file"
                      name="day_use[day_use_schedules][][photo]"
                    ></input>
                  </div>
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
                          onChange={(e) =>
                            handleWeekdayChange(
                              "closes_at",
                              e.target.value,
                              index
                            )
                          }
                        />
                      </div>
                      {restoreErrorForField("opens_at", weekday.value)}
                      {restoreErrorForField("closes_at", weekday.value)}
                    </div>
                    <div className="f-48 flex center gap-24">
                      <div className="f-1x">
                        <label htmlFor="">Duração do slot</label>
                        <input
                          className="form-control my-2"
                          type="text"
                          name="day_use[day_use_schedules][][slot_duration_in_minutes]"
                          placeholder="Duração do slot"
                          value={
                            weekday.dayUseSchedule.slot_duration_in_minutes
                          }
                          onChange={(e) =>
                            handleWeekdayChange(
                              "slot_duration_in_minutes",
                              e.target.value,
                              index
                            )
                          }
                        />
                      </div>
                      <div className="f-1x">
                        <label htmlFor="">Quantidade de passes por slot</label>
                        <input
                          className="form-control my-2"
                          type="text"
                          name="day_use[day_use_schedules][][quantity_per_slot]"
                          placeholder="Limite de ingressos por slot"
                          value={weekday.dayUseSchedule.quantity_per_slot}
                          onChange={(e) =>
                            handleWeekdayChange(
                              "quantity_per_slot",
                              e.target.value,
                              index
                            )
                          }
                        />
                      </div>
                    </div>
                  </div>
                </div>

                <label htmlFor="">Tipos de passes</label>
                {restoreErrorForField("pass_types", weekday.value)}
                {weekday.dayUseSchedule.day_use_schedule_pass_types
                  .filter((pass_type) => !pass_type.deleted_at)
                  .map((passType, passTypeIndex) => {
                    return (
                      <div className="mb-4" key={passTypeIndex}>
                        <input
                          type="hidden"
                          name="day_use[day_use_schedules][][day_use_schedule_pass_types][][id]"
                          value={passType.id}
                        />
                        <div className="flex center between gap-24">
                          <div className="f-1x">
                            <input
                              className="form-control my-2"
                              type="text"
                              name="day_use[day_use_schedules][][day_use_schedule_pass_types][][name]"
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
                            {restoreErrorForPassTypeField(
                              "name",
                              weekday.value,
                              passTypeIndex
                            )}
                          </div>

                          <div className="f-1x">
                            <input
                              className="form-control my-2"
                              type="number"
                              name="day_use[day_use_schedules][][day_use_schedule_pass_types][][price_in_cents]"
                              placeholder="Preço em centavos"
                              value={passType.price_in_cents}
                              onChange={(e) =>
                                handlePassTypeUpdate(
                                  "price_in_cents",
                                  e.target.value,
                                  weekday,
                                  passTypeIndex
                                )
                              }
                            />
                            {restoreErrorForPassTypeField(
                              "price_in_cents",
                              weekday.value,
                              passTypeIndex
                            )}
                          </div>

                          <div className="f-1x">
                            <input
                              className="form-control my-2"
                              type="number"
                              name="day_use[day_use_schedules][][day_use_schedule_pass_types][][number_of_accesses_granted]"
                              placeholder="Número de acessos por passe"
                              value={passType.number_of_accesses_granted}
                              onChange={(e) =>
                                handlePassTypeUpdate(
                                  "number_of_accesses_granted",
                                  e.target.value,
                                  weekday,
                                  passTypeIndex
                                )
                              }
                            />
                          </div>

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
                  })}

                <div className="text-center">
                  <p
                    className="btn btn-success p-3 text-center mt-5"
                    onClick={() => addPassType(weekday)}
                  >
                    <i className="fa fa-plus-square"></i>
                    <span className="px-3">Adicionar tipo de passe</span>
                  </p>
                </div>
              </div>
            </div>
          );
        })}
      </div>
    </div>
  );
}
