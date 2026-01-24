import { useEffect } from 'react';
import { Header } from './components/layout/Header';
import { Sidebar } from './components/layout/Sidebar';
import { MainContent } from './components/layout/MainContent';
import { Footer } from './components/layout/Footer';
import { RandomizeModal } from './components/modals/RandomizeModal';
import { useRandomizerStore } from './store';
import './index.css';

function App() {
  const { checkApiConnection, checkRomStatus } = useRandomizerStore();

  // Check API connection and ROM status on mount
  useEffect(() => {
    checkApiConnection();
    checkRomStatus();
  }, [checkApiConnection, checkRomStatus]);

  return (
    <div className="flex flex-col h-screen bg-slate-900 text-white">
      <Header />
      <div className="flex flex-1 overflow-hidden">
        <Sidebar />
        <MainContent />
      </div>
      <Footer />
      <RandomizeModal />
    </div>
  );
}

export default App;
