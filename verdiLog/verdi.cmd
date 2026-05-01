simSetSimulator "-vcssv" -exec "/home/st32/HomeWorks/hw4/simv" -args
debImport "-dbdir" "/home/st32/HomeWorks/hw4/simv.daidir"
debLoadSimResult /home/st32/HomeWorks/hw4/waves.fsdb
wvCreateWindow
verdiSetActWin -dock widgetDock_MTB_SOURCE_TAB_1
srcSignalView -on
verdiSetActWin -dock widgetDock_<Signal_List>
srcHBSelect "top.dut_if" -win $_nTrace1
srcSetScope "top.dut_if" -delim "." -win $_nTrace1
srcHBSelect "top.dut_if" -win $_nTrace1
verdiSetActWin -dock widgetDock_<Inst._Tree>
srcHBSelect "top" -win $_nTrace1
srcSetScope "top" -delim "." -win $_nTrace1
srcHBSelect "top" -win $_nTrace1
srcSignalViewSelect "top.clk"
srcSignalViewAddSelectedToWave -win $_nTrace1
verdiSetActWin -dock widgetDock_<Signal_List>
srcHBSelect "top.dut_if" -win $_nTrace1
srcSetScope "top.dut_if" -delim "." -win $_nTrace1
srcHBSelect "top.dut_if" -win $_nTrace1
verdiSetActWin -dock widgetDock_<Inst._Tree>
srcSignalViewSelect "top.dut_if.write"
srcSignalViewAddSelectedToWave -win $_nTrace1
verdiSetActWin -dock widgetDock_<Signal_List>
srcSignalViewSelect "top.dut_if.read"
srcSignalViewAddSelectedToWave -win $_nTrace1
srcSignalViewSelect "top.dut_if.address\[15:0\]"
srcSignalViewAddSelectedToWave -win $_nTrace1
srcSignalViewSelect "top.dut_if.data_in\[7:0\]"
srcSignalViewAddSelectedToWave -win $_nTrace1
srcSignalViewSelect "top.dut_if.data_out\[8:0\]"
srcSignalViewAddSelectedToWave -win $_nTrace1
srcSignalViewSelect "top.dut_if.data_out\[8:0\]"
srcSignalViewExpand "top.dut_if.data_out\[8:0\]"
verdiSetActWin -win $_nWave2
srcSignalViewSelect "top.dut_if.clk"
verdiSetActWin -dock widgetDock_<Signal_List>
srcHBSelect "top.dut" -win $_nTrace1
verdiSetActWin -dock widgetDock_<Inst._Tree>
srcHBSelect "top.dut" -win $_nTrace1
srcHBSelect "top.dut" -win $_nTrace1
srcSetScope "top.dut" -delim "." -win $_nTrace1
srcHBSelect "top.dut" -win $_nTrace1
srcSignalViewExpand "top.dut.mif" -extRefSignal
verdiSetActWin -dock widgetDock_<Signal_List>
verdiSetActWin -win $_nWave2
wvSetCursor -win $_nWave2 365587.695071 -snap {("G1" 1)}
wvZoomAll -win $_nWave2
wvSetCursor -win $_nWave2 707048.187023 -snap {("G1" 2)}
wvSetCursor -win $_nWave2 823275.286260 -snap {("G1" 2)}
wvSetCursor -win $_nWave2 832960.877863 -snap {("G1" 2)}
wvSetCursor -win $_nWave2 852332.061069 -snap {("G1" 2)}
wvSetCursor -win $_nWave2 1201013.358779 -snap {("G1" 6)}
wvSetCursor -win $_nWave2 1181642.175573 -snap {("G1" 6)}
wvSetCursor -win $_nWave2 1423781.965649 -snap {("G1" 6)}
wvZoom -win $_nWave2 1326926.049618 1385039.599237
wvZoomAll -win $_nWave2
wvSetCursor -win $_nWave2 1394725.190840 -snap {("G1" 6)}
wvSetCursor -win $_nWave2 1394725.190840 -snap {("G1" 6)}
wvSetCursor -win $_nWave2 1377005.813953
wvSetCursor -win $_nWave2 1394725.190840
wvSetCursor -win $_nWave2 1995231.870229
wvZoomIn -win $_nWave2
wvZoomIn -win $_nWave2
wvZoomIn -win $_nWave2
wvZoomIn -win $_nWave2
