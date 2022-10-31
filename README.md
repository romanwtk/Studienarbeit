# Konstruktion eines kryptographischen Verfahrens basierend auf Reed-Solomon-Codes und Diskussion möglicher Angriffsmethoden
## Zielsetzung der Arbeit
Code-basierte Kryptosysteme werden durch ihre mögliche Quantensicherheit zu einem aussichtsreichen Forschungsgegenstand der Kryptographie. 
Für das nach McEliece benannte Kryptosystem, das auf Goppa-Codes basiert, wurde bislang kein geeignetes Angriffsverfahren entdeckt. 

Im Rahmen dieser Arbeit soll ein auf eine Idee von H. Niederreiter zurückgehendes Kryptosystem nach Vorbild des McEliece-Verfahrens entwickelt werden, 
das auf Reed-Solomon-Codes basiert. Da dieses Verfahren aufgrund der Eigenschaften von Reed-Solomon-Codes angreifbar ist (Sidelnikov-Shestakov-Attacken), 
sollen darüber hinaus mögliche Angriffsverfahren analysiert und diskutiert werden.

## Gliederung der Arbeit
1. Theoretische Hintergründe

    - Lineare fehlerkorrigierende Codes, besonders RS-Codes
    - McEliece-Kryptosystem
    - Niederreiter-Schema

2. Konstruktion eines Kryptosystems auf Basis der Idee von Harald Niederreiter

    - Mathematische Darstellung in Algorithmen, Definitionen und Formelzeichen
    - Implementierung in Python
    - Beispiele

3. Eigenschaften des dargestellten Verfahrens

    - Vergleich zu McEliece, Niederreiter-Publikationen
    - Komplexität
    - Sicherheit nach Sidelnikov & Shestakov

4. Angriffe

    - Sidelnikov & Shestakov
    - RS-Code-Verwundbarkeiten
    - Seitenkanalangriffe?
    - ...?

5. Fazit und Bewertung


## Quellensammlung
[Buchmann et al. - Post-Quantum Cryptography, Chapter "Code-based Cryptography" by Overbeck & Sendrier](https://rdcu.be/cYCx9)
