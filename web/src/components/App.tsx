import React, {useState, useEffect} from 'react';
import './App.css'
import {debugData} from "../utils/debugData";
import { useVisibility } from '../providers/VisibilityProvider';
import Form from './Form';
import Header from './Header';
import { useNuiEvent } from '../hooks/useNuiEvent';
import { formatDate } from '../utils/formatString';

export interface IFormData {
  patient: string;
  medication: string;
  quantity: string;
  notes: string;
  signature: string;
}

export interface Medication {
  item: string;
  label: string;
}

interface DocData {
  name: string;
}

interface IPrescriptData {
  docInfo: DocData;
  formInfo: IFormData | null;
  createDate: string;
  isReadOnly: boolean;
}

debugData([
  {
    action: 'setupForm',
    data: {
      docInfo: {
        name: "Dr Glowie",
      },
      medInfo: [
        {item: "amoxicillin", label: "Amoxicillin"},
        {item: "hydromorphone", label: "Hydromorphone"},
        {item: "oxycodone", label: "Oxycodone"},
      ],
      unixTime: 1683869960,
    },
  }
])

debugData([
  {
    action: 'setupReadOnly',
    data: {
      docInfo: {
        name: "Dr Glowie",
      },
      formInfo: {
        patient: "Jin Pain",
        medication: "Hydromorphone",
        quantity: "32",
        notes: "Some notes here :)",
        signature: "Super Cool Signature",
      },
      unixTime: 1683869960,
    },
  }
])

const App: React.FC = () => {
  const { visible, setVisible } = useVisibility();
  const [medList, setMedList] = useState<Medication[]>([]);
  const [prescriptData, setPrescriptData] = useState<IPrescriptData>({
    docInfo: {name: ""},
    formInfo: null,
    createDate: "",
    isReadOnly: true,
  })

  useNuiEvent("setupForm", (data: {docInfo: DocData, medInfo: Medication[], unixTime: number}) => {
    const formattedDate = formatDate(data.unixTime);
    setPrescriptData(prevData => {
      return {
        ...prevData,
        docInfo: data.docInfo,
        formInfo: null,
        createDate: formattedDate,
        isReadOnly: false,
      }
    })
    setMedList(data.medInfo);
    setVisible(true);
  })

  useNuiEvent("setupReadOnly", (data: {docInfo: DocData, formInfo: IFormData, unixTime: number}) => {
    const formattedDate = formatDate(data.unixTime);
    setPrescriptData(prevData => {
      return {
        ...prevData,
        docInfo: data.docInfo,
        formInfo: data.formInfo,
        createDate: formattedDate,
        isReadOnly: true,
      }
    })
    setVisible(true);
  })
    
  return (
    <div id="container">
      <div className="notepad-top"></div>
      <div id="prescript-container">
        <Header 
          name={prescriptData.docInfo.name}
        />
        <Form
          medList={medList}
          createDate={prescriptData.createDate}
          prescript={prescriptData.formInfo}
          isReadOnly={prescriptData.isReadOnly}
        />
      </div>
    </div>
  );
}

export default App;
