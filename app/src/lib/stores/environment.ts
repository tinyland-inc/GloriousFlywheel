import type { Environment } from "$lib/types";

let currentEnv = $state<Environment>("beehive");

export function getEnvironment(): Environment {
  return currentEnv;
}

export function setEnvironment(env: Environment) {
  currentEnv = env;
}

export const environment = {
  get current() {
    return currentEnv;
  },
  set current(env: Environment) {
    currentEnv = env;
  },
  get isBeehive() {
    return currentEnv === "beehive";
  },
  get isRigel() {
    return currentEnv === "rigel";
  },
  get domain() {
    return currentEnv === "beehive" ? "beehive.bates.edu" : "rigel.bates.edu";
  },
};
