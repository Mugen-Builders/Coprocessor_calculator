<br>
<p align="center">
    <img src="https://github.com/Mugen-Builders/.github/assets/153661799/7ed08d4c-89f4-4bde-a635-0b332affbd5d" align="center" width="20%">
</p>
<br>
<br>
<p align="center">
	<img src="https://img.shields.io/github/license/Nonnyjoe/OpenQuest?style=default&logo=opensourceinitiative&logoColor=white&color=79F7FA" alt="license">
	<img src="https://img.shields.io/github/last-commit/Nonnyjoe/OpenQuest?style=default&logo=git&logoColor=white&color=868380" alt="last-commit">
</p>

# Simple Calculator Template - Cartesi Coprocessor

This repo contains an application template that demonstrates a simple calculator running on Cartesi Co-processor's framework. The offchain/ Coprocessor component of the application is implemented in [Rust](./app/), while the onchain contracts is written in [Solidity](./contracts/).

## How does it work?

A user can deploy the coprocessor application as well as the solidity contract, then interact with the calculator using cast to call any of the four arithmetic operations (addition, subtraction, division or multiplication) passing the necessary arguments. This computation request is recorded then confirmed to be unique and have not been executed before, after which it is sent to the coprocessor component. The coprocessor will execute the request then the result generated is encoded and sent back to the contract where it is decoded and finally stored properly.

## Project Structure

- `app/` - Off chain/ Coprocessor implementation in Rust.
- `contracts/` - Smart contract with custom logic and function to request calculations from the coprocessor.

## Setup Instructions for Devnet

Below steps will assume that you've cloned this repo to your local machine and you already have Docker Desktop, Cartesi CLI and Foundry installed.

### 1. Install `cartesi` CLI

Cartesi CLI will help us build, deploy and run local environment with ease.

```shell
 npm i -g @cartesi/cli
```

### 2. Run the Coprocessor devnet environment

Before running the application, you need to have the Coprocessor devnet environment running. It will spin up a local operator in devnet mode that will host the application backend.

On your terminal, start the devnet environment:

```shell
cartesi coprocessor start
```

You can open Docker Desktop to see the running containers and corresponding logs. application logs are visible in the `cartesi-coprocessor-operator` container.

To turn down the environment later, run:

```shell
cartesi coprocessor stop
```

### 3. Build the app and contract folders

- Open another terminal tab and `cd` into the `app` folder.

    Run the build command:

    ```shell
    cartesi build
    ```

    At this point, you should see the `machine hash` by running:

    ```shell
    cartesi hash
    ```

    Copy and past this hash somewhere safe as it would be used in a later step.

- `cd` into the `contracts` folder then run the below command t build.

  ```shell
  forge soldeer install
  ```

    ```shell
  forge build
  ```

### 4. Deploy `calculator` Smart Contract

To deploy the contract, `cd` out of the `contracts` folder, ensure you're in the root (Coprocessor_calculator) folder then run the below command:

```shell
cartesi coprocessor deploy Calculator --constructorArgs <task_issuer_address> <machine_hash>
```

**NOTE:** You can get the `task_issuer_address` from the `address-book` by runing the command:

  ```shell
  cartesi address-book
  ```

While the `cartesi hash` as shown in the previous step will return the machine hash.

Copy the deployed contract address you get from above command and save it for interaction using cast.

## License

MIT
