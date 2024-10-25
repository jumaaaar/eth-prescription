# Prescription Medication Script for ESX
Converted from QB to ESX Thank you to [glow_prescription](https://github.com/christikat/glow_prescription) for creating this wonderful script

* I Have did some adjustments to the script so it can work with ox_inventory
* feel free to use it on your own 

## Description
A simple prescription resource for QBCore, created using React. It allows players to fill out prescriptions, and give them to other players. With the prescription, players can go to the pharmacy and interact with the spawned in ped to retrieve their medications.

<div align="center">
    <img height="500" src="https://i.imgur.com/rcVi1WM.png" alt="Prescription UI" />
</div>

## Key Features
- Only Specific job can use the item
- Prescription form with drop down menu of available medications found in the config
- Prescriptions expire based on time set in config
- Ability to prescribe specific quantitys of medication
- Each use of a medication will reduce items metadata by one dose and remove item when no doses remain
- Using a the prescription will display a read only version of the UI

## Installation
- Download latest release at https://github.com/jumaaaar/eth-prescription/releases/
- Open the ZIP and move `eth-prescription` into your resource folder and `ensure eth-prescription` in server.cfg
- Add `prescriptionpad`, `prescription`, and all medications in your ox_inventory
